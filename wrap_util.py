#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on June 3 11:38:53 2020

@author: charles
"""

import src.oracle_export as ora_export

# type에 'PACKAGE'를 파라메터로 전달하면 package, package body를 가지고 올 수 있으며
# type에 'PACKAGE_BODY'를 파라메터로 전달하면 package body만 가지고 온다
# 1. Oracle Package Export
# 2. sftp를 이용해서 Oracle Server에 접속
# 2.1 환경 설정 파일 로드 source ~/.bash_profile; 
# 2.2 /bin 디렉토레에 있는 wrap를 이용해서 wrp 파일 생성
# 3. warp 파일을 로컬로 다운로드
# 4. Package Compile
# 5. Server에 생성한 파일 삭제

if __name__ == "__main__":
    with ora_export.Exp('FUNCTION', '*', 'CBSADM') as exp:
        exp.export()

    # with ora_export.Exp('PROCEDURE', '*', 'CBSADM') as exp:
    #     exp.export()
    
    # with ora_export.Exp('PACKAGE_BODY', '*', 'CBSADM') as exp:
    #     exp.export()

        # exp.expFile()

        # exp.upFile()

        # exp.exeCmd()
        
        # exp.connSftp()
        
        # exp.dnFile()
        
        # exp.compile()

        # exp.rmFile()

