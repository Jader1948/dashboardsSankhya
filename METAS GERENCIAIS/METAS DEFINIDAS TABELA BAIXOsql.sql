
 
 SELECT 
	(CASE WHEN W.SINAL_MES = 'JAN' THEN 'JANEIRO'
		WHEN W.SINAL_MES='FEV' THEN 'FEVEREIRO' 
		WHEN W.SINAL_MES='MAR' THEN 'MARCO'
		WHEN W.SINAL_MES='ABR' THEN 'ABRIL'
		WHEN W.SINAL_MES='MAI' THEN 'MAIO'
		WHEN W.SINAL_MES='JUN' THEN 'JUNHO'
		WHEN W.SINAL_MES='JUL' THEN 'JULHO'
		WHEN W.SINAL_MES='AGO' THEN 'AGOSTO'
		WHEN W.SINAL_MES='SET' THEN 'SETEMBRO'
		WHEN W.SINAL_MES='OUT' THEN 'OUTUBRO'
		WHEN W.SINAL_MES='NOV' THEN 'NOVEMBRO'
		WHEN W.SINAL_MES='DEZ' THEN 'DEZEMBRO' END)AS MES,

	(CASE WHEN W.SINAL_VEN='JAN' THEN W.VENDA 
		 WHEN W.SINAL_VEN='FEV' THEN W.VENDA
		 WHEN W.SINAL_VEN='MAR' THEN W.VENDA
		 WHEN W.SINAL_VEN='ABR' THEN W.VENDA
		 WHEN W.SINAL_VEN='MAI' THEN W.VENDA
		 WHEN W.SINAL_VEN='JUN' THEN W.VENDA
		 WHEN W.SINAL_VEN='JUL' THEN W.VENDA
		 WHEN W.SINAL_VEN='AGO' THEN W.VENDA
		 WHEN W.SINAL_VEN='SET' THEN W.VENDA
		 WHEN W.SINAL_VEN='OUT' THEN W.VENDA
		 WHEN W.SINAL_VEN='NOV' THEN W.VENDA
		 WHEN W.SINAL_VEN='DEZ' THEN W.VENDA END)AS FATURADO,
		
	(CASE WHEN W.SINAL_MET='JAN' THEN W.META
		WHEN W.SINAL_MET='FEV' THEN W.META
		WHEN W.SINAL_MET='MAR' THEN W.META
		WHEN W.SINAL_MET='ABR' THEN W.META
		WHEN W.SINAL_MET='MAI' THEN W.META
		WHEN W.SINAL_MET='JUN' THEN W.META
		WHEN W.SINAL_MET='JUL' THEN W.META
		WHEN W.SINAL_MET='AGO' THEN W.META
		WHEN W.SINAL_MET='SET' THEN W.META
		WHEN W.SINAL_MET='OUT' THEN W.META
		WHEN W.SINAL_MET='NOV' THEN W.META
		WHEN W.SINAL_MET='DEZ' THEN W.META END)AS META,

	(CASE WHEN W.SINAL_PER='JAN' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='FEV' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='MAR' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='ABR' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='MAI' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='JUN' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='JUL' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='AGO' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='SET' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='OUT' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='NOV' THEN W.PERCENTUAL
		WHEN W.SINAL_PER='DEZ' THEN W.PERCENTUAL END) AS PERCENTUAL
 FROM(

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 1 THEN 'JANEIRO' END)AS MES,'JAN' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 1 THEN Y.VENDA END)AS VENDA,'JAN' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 1 THEN Y.META END)AS META,'JAN'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 1 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'JAN' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  MONTH(CAB.DTNEG) = 1
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE MONTH(CAB.DTNEG) = 1
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
MONTH(DTREF) = 1
--DTREF between '2023/01/01' and '2023/01/31'
)X
 GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.META, Y.NAT


UNION ALL


SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 2 THEN 'FEVEREIRO' END)AS MES,'FEV' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 2 THEN Y.VENDA END)AS VENDA,'FEV' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 2 THEN Y.META END)AS META,'FEV'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 2 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'FEV' AS SINAL_PER ,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE MONTH(CAB.DTNEG) = 2
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE MONTH(CAB.DTNEG) = 2
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
MONTH(DTREF) = 2
--DTREF between '2023/02/01' and '2023/02/28'
)X
 GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.META, Y.NAT


UNION ALL
SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 3 THEN 'MARCO' END)AS MES,'MAR' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 3 THEN Y.VENDA END)AS VENDA,'MAR' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 3 THEN Y.META END)AS META,'MAR'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 3 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'MAR' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE MONTH(CAB.DTNEG) = 3
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE MONTH(CAB.DTNEG) = 3
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
MONTH(DTREF) = 3
--DTREF between '2023/03/01' and '2023/03/31'
)X
 GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.META,Y.NAT


UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 4 THEN 'ABRIL' END)AS MES,'ABR' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 4 THEN Y.VENDA END)AS VENDA,'ABR' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 4 THEN Y.META END)AS META,'ABR'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 4 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'ABR' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE MONTH(CAB.DTNEG) = 4
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE MONTH(CAB.DTNEG) = 4
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
MONTH(DTREF) = 4
--DTREF between '2023/04/01' and '2023/04/30'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META

UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 5 THEN 'MAIO' END)AS MES,'MAI' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 5 THEN Y.VENDA END)AS VENDA,'MAI' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 5 THEN Y.META END)AS META,'MAI'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 5 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'MAI' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/05/01' and '2023/05/31'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/05/01' and '2023/05/31'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/05/01' and '2023/05/31'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META

UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 6 THEN 'JUNHO' END)AS MES,'JUN' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 6 THEN Y.VENDA END)AS VENDA,'JUN' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 6 THEN Y.META END)AS META,'JUN'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 6 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'JUN' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/06/01' and '2023/06/30'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/06/01' and '2023/06/30'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/06/01' and '2023/06/30'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META


UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 7 THEN 'JULHO' END)AS MES,'JUL' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 7 THEN Y.VENDA END)AS VENDA,'JUL' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 7 THEN Y.META END)AS META,'JUL'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 7 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'JUL' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/07/01' and '2023/07/31'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/07/01' and '2023/07/31'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/07/01' and '2023/07/31'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META

UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 8 THEN 'AGOSTO' END)AS MES,'AGO' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 8 THEN Y.VENDA END)AS VENDA,'AGO' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 8 THEN Y.META END)AS META,'AGO'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 8 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'AGO' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/08/01' and '2023/08/31'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/08/01' and '2023/08/31'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/08/01' and '2023/08/31'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META


UNION ALL


SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 9 THEN 'SETEMBRO' END)AS MES,'SET' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 9 THEN Y.VENDA END)AS VENDA,'SET' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 9 THEN Y.META END)AS META,'SET'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 9 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'SET' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/09/01' and '2023/09/30'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/09/01' and '2023/09/30'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/09/01' and '2023/09/30'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META


UNION ALL


SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 10 THEN 'OUTUBRO' END)AS MES,'OUT' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 10 THEN Y.VENDA END)AS VENDA,'OUT' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 10 THEN Y.META END)AS META,'OUT'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 10 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'OUT' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/10/01' and '2023/10/31'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/10/01' and '2023/10/31'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/10/01' and '2023/10/31'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META

UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 11 THEN 'NOVEMBRO' END)AS MES,'NOV' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 11 THEN Y.VENDA END)AS VENDA,'NOV' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 11 THEN Y.META END)AS META,'NOV'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 11 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'NOV' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/11/01' and '2023/11/30'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/11/01' and '2023/11/30'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/11/01' and '2023/11/30'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META

UNION ALL

SELECT DISTINCT
	(CASE WHEN MONTH(MET.DTREF) = 12 THEN 'DEZEMBRO' END)AS MES,'DEZ' AS SINAL_MES ,
	(CASE WHEN MONTH(MET.DTREF) = 12 THEN Y.VENDA END)AS VENDA,'DEZ' AS SINAL_VEN ,
	(CASE WHEN MONTH(MET.DTREF) = 12 THEN Y.META END)AS META,'DEZ'AS SINAL_MET,
	(CASE WHEN MONTH(MET.DTREF) = 12 THEN ((Y.VENDA / Y.META)*100) END)AS PERCENTUAL, 'DEZ' AS SINAL_PER,
	Y.NAT AS NATUREZA
FROM( 

SELECT
	SUM(CASE WHEN X.SINAL= 'V' THEN X.VL_TOTAL ELSE 0 END) AS VENDA,
	SUM(CASE WHEN X.SINAL= 'M' THEN X.VL_TOTAL ELSE 0 END) AS META,
	X.NAT

	FROM (
SELECT ROUND(SUM(Z.VLR_FATURAMENTO),2) AS VL_TOTAL,'V' AS SINAL, Z.CODNAT AS NAT FROM (
SELECT
	X.*,  SUM((CASE WHEN X.CODTIPOPER IN (1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305) THEN -1 *(ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC) 
			 ELSE (ITE.QTDNEG*ITE.VLRUNIT - ITE.VLRDESC)END)) AS VLR_FATURAMENTO,
	CAB.DTNEG AS DATA_FATURAMENTO
	FROM  (
SELECT 
	CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	(SELECT TOP 1 NUNOTA FROM TGFVAR WHERE NUNOTAORIG = CAB.NUNOTA) AS NFE
FROM TGFCAB CAB
WHERE  CAB.DTNEG BETWEEN '2023/12/01' and '2023/12/31'
AND CAB.TIPMOV = 'P'
AND CAB.CODNAT = 1010100 
AND CAB.CODTIPOPER NOT IN (900,1259,1200,1269,1266,1270,1293,1294)
AND CAB.STATUSNOTA='L'
GROUP BY CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER
UNION 
SELECT CAB.NUNOTA,
	CAB.DTNEG,
	CAB.CODNAT,
	CAB.STATUSNOTA,
	CAB.CODTIPOPER,
	CAB.NUNOTA AS NFE
FROM TGFCAB CAB 
WHERE CAB.DTNEG BETWEEN '2023/12/01' and '2023/12/31'
AND TIPMOV = 'D' 
AND CODNAT = 1010100
AND  CAB.CODTIPOPER IN(1200,1201,1235,1236,1248,1249,1264,1265,1293,1304,1305)
AND STATUSNOTA='L'
)X
	INNER JOIN TGFITE ITE ON ITE.NUNOTA = X.NUNOTA
	INNER JOIN TGFCAB CAB ON CAB.NUNOTA = X.NFE

GROUP BY X.NUNOTA,
	X.DTNEG,
	X.CODNAT,
	X.STATUSNOTA,
	X.CODTIPOPER,
	X.NFE,
	CAB.DTNEG

)Z

GROUP BY Z.CODNAT

 UNION ALL

SELECT ROUND(PREVREC,2) AS VL_TOTAL, 'M' AS SINAL, CODNAT AS NAT
FROM TGMMET 
WHERE CODMETA = 21 AND 
CODNAT = 1010100 AND 
DTREF between '2023/12/01' and '2023/12/31'
)X

GROUP BY X.NAT

)Y
	INNER JOIN TGMMET MET ON MET.CODNAT = Y.NAT


GROUP BY Y.VENDA, MET.DTREF, Y.NAT, Y.META 


)W

INNER JOIN TGFMET MET ON MET.CODNAT = W.NATUREZA

WHERE W.VENDA IS NOT NULL 
--AND MONTH(MET.DTREF) < 3
--AND  MET.DTREF = DATEADD(DD, -DAY(DATEADD(M, 1, GETDATE())), DATEADD(M, 0, GETDATE())))

GROUP BY W.META, W.MES, W.VENDA, W.PERCENTUAL, W.SINAL_MES,W.SINAL_MET, W.SINAL_PER, W.SINAL_VEN

