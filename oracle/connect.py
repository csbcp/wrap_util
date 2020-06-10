#------------------------------------------------------------------------------
# connect.py (Section 1.2 and 1.3)
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Copyright (c) 2017, 2018, Oracle and/or its affiliates. All rights reserved.
#------------------------------------------------------------------------------

from __future__ import print_function

import cx_Oracle
import config.db_config as db_config

class Oracle():
    
    def connect():
        """ Connect to the database. """

        try:
            con = cx_Oracle.connect(db_config.user, db_config.pw, db_config.dsn)
            print("Database version:", con.version)
            return con
        except cx_Oracle.DatabaseError as e:
            # Log error as appropriate
            raise

        # If the database connection succeeded create the cursor
        # we-re going to use.
        cursor = con.cursor()

    def disconnect(self):
        """
        Disconnect from the database. If this fails, for instance
        if the connection instance doesn't exist, ignore the exception.
        """

        try:
            cursor.close()
            con.close()
        except cx_Oracle.DatabaseError:
            pass

    def execute(sql, bindvars=None, commit=False):
        """
        Execute whatever SQL statements are passed to the method;
        commit if specified. Do not specify fetchall() in here as
        the SQL statement may not be a select.
        bindvars is a dictionary of variables you pass to execute.
        """

        try:
            cursor.execute(sql, bindvars)
        except cx_Oracle.DatabaseError as e:
            # Log error as appropriate
            raise

        # Only commit if it-s necessary.
        if commit:
            db.commit()