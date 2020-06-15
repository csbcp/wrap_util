#!/usr/data/env python3
# -*- coding: utf-8 -*-
"""
Created on June 3 11:38:53 2020

@author: charles
"""

from __future__ import print_function

import sys, os
import cx_Oracle
import itertools
import paramiko
import time
import config.db_config as db_config
import oracle.sql as sql

from oracle.connect import Oracle
from src.sftp import Ftp

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

class Exp:
    def __init__(self, type, name, user):
        self.__type = type
        self.__user = user
        self.__name = name

        if self.__type == 'PACKAGE_BODY':
            self.__ext = '.pkb'
        elif self.__type == 'FUNCTION':
            self.__ext = '.fnc'
        elif self.__type == 'PROCEDURE':
            self.__ext = '.prc'

    def __enter__(self):
        self.__db = Oracle.connect()
        self.__cursor = self.__db.cursor()
        return self 
  
    def __exit__(self, type, value, traceback): 
        self.__db.close()

    def export(self):
        if self.__name == '*':
            if self.__type == 'PACKAGE_BODY':
                Exp.getOracleObject(self, 'PACKAGE')
            else:
                Exp.getOracleObject(self, self.__type)
        else:
            Exp.exp_file()    

    def getOracleObject(self, object_type):
        object_name_row = [row for row in self.__cursor.execute(sql.get_pkg_list, ojt = object_type)]

        for row in object_name_row:
            self.__name  = row[0]
            self.__fname = row[0] + self.__ext
            self.__wname = row[0] + '.wrp'
            print('__name {}, __fname {}, __wname {}'.format(self.__name, self.__fname, self.__wname))
            Exp.exp_file(self, self.__type, self.__name, self.__user)
            Exp.upload_file(self)
            Exp.execute_cmd(self)
            Exp.download_file(self)

    def exp_file(self, type, name, user):
        get_ddl = """select dbms_metadata.get_ddl(:typ, :nm, :usr) from dual"""
        try:
            self.__cursor.execute(get_ddl, typ = type, nm = name, usr = user)

            # wrap 파일은 처리하지 않는다.
            while True:
                clobData = self.__cursor.fetchone()
                if clobData is None:
                    break
                elif str(clobData[0]).find('wrapped') != -1:
                    l_source = clobData[0];
                    f = open('./data/{}'.format(self.__fname), "w")
                    f.write(str(l_source).replace('EDITIONABLE ', ''))
                    f.close()

                    print (bcolors.OKGREEN, "type is {}, name is {}, user is {} : export succesfully ... ".format(self.__type, self.__name, self.__user))
                    return True
                else:
                    print (bcolors.OKBLUE, "Skip, {} is a wrap file.".format(self.__name))
                    return False                
        except cx_Oracle.DatabaseError as e:
            error, = e.args
            print(bcolors.WARNING ,'Error message : {}'.format(error.message))
            return False

    def compile(self):
        with open('./data/{}'.format(self.__wname), "r") as sqlFile:
            sql = sqlFile.read()
            self.__cursor.execute(sql)

        print (bcolors.OKGREEN, "{} file compile succesfully".format(self.__fname))

    def execute_cmd(self):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            ssh.connect(db_config.ORA_HOST, username = db_config.ORA_USER, password = db_config.ORA_PASS)
        except paramiko.ssh_exception.AuthenticationException:
            print('Password failed connecting to {}'.format(db_config.ORA_HOST))
            exit()
        except TimeoutError:
            print(bcolors.FAIL, 'Timed out connecting to {}'.format(db_config.ORA_HOST))
            exit()
        except ssh.gaierror:
            print(bcolors.FAIL, 'Cannot find host named {}'.format(db_config.ORA_HOST))
            exit()
        except:
            print(bcolors.FAIL, 'Unknown error connecting to {}'.format(db_config.ORA_HOST))
            exit()

        stdin, stdout, stderr = ssh.exec_command('hostname')
        out=stdout.readlines()
        conhost = out[0][0:-1]
        print(bcolors.OKGREEN, 'Connected to ' + conhost + ' attempting to connect to {}'.format(db_config.ORA_HOST))
        
        ora_bin = db_config.ORA_BIN
        command = """ source ~/.bash_profile; {}wrap iname={}{} oname={}{}; pwd; """.format(ora_bin, ora_bin, self.__fname, ora_bin, self.__wname)
        print(command)

        stdin, stdout, stderr = ssh.exec_command(command)
        # print(stdout.readlines())
        print (bcolors.OKGREEN, "Create wrap file succesfully".format(self.__fname))

        ssh.close()

    def conn_sfpt(self):

        Ftp.connSftp();
        print (bcolors.OKGREEN, "Connection FTP succesfully")

    def upload_file(self):
    
        Ftp.upload_file(self, self.__fname)
        print (bcolors.OKGREEN, "The {} is successfully uploaded to server".format(self.__fname))

    def download_file(self):

        Ftp.download_file(self, self.__wname)
        print (bcolors.OKGREEN, "The {} is successfully downloaded from server".format(self.__fname))
       
    def remove_file(self):

        Ftp.remove_file(self, self.__fname, self.__wname)
        print (bcolors.OKGREEN, "The {} file on the server was successfully removed".format(self.__fname))
    
    # def mvFile(self):
        # fs.move_file('/data/{}'.format(self.__fname), '/Users/charles/GitHub/MTCSQL/Package_Crypto/{}'.format(self.__wname))     