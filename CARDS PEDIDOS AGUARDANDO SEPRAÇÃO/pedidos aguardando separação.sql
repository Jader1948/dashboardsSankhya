


SELECT CAB.NUNOTA, CAB.DTNEG, PAR.RAZAOSOCIAL, VEN.APELIDO
FROM TGFCAB CAB
	INNER JOIN TGFPAR PAR ON PAR.CODPARC = CAB.CODPARC
	INNER JOIN TGFVEN VEN ON VEN.CODVEND = CAB.CODVEND
WHERE CAB.TIPMOV='P' AND CAB.AD_STATUS_PED= 'ASE' AND CAB.CODNAT = 1010100
AND DAY(CAB.DTNEG) = DAY(GETDATE()) AND MONTH(CAB.DTNEG) = MONTH(GETDATE()) AND YEAR(CAB.DTNEG)= YEAR(GETDATE())


SELECT COUNT(NUNOTA) QTD
FROM TGFCAB 
WHERE TIPMOV='P' AND AD_STATUS_PED= 'ASE' AND CODNAT = 1010200 
AND DAY(DTNEG) = DAY(GETDATE())

SELECT COUNT(NUNOTA) QTD
FROM TGFCAB 
WHERE TIPMOV='P' AND AD_STATUS_PED= 'ASE' AND CODNAT = 1010300
AND DAY(DTNEG) = DAY(GETDATE()) AND MONTH(DTNEG) = MONTH(GETDATE()) AND YEAR(DTNEG)= YEAR(GETDATE())

