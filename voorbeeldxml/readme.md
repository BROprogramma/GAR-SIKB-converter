# Uitleg voorbeeldbestanden

## onderzoek.xml
Wat zit er o.a. in?
- Project
- Meetpunten
    - Filters
    - Veldmonsters (water)
- Analysemonster (water)
    - AnalyseResultaat
        - Procedure

Dit is een voorbeeld hoe het werkt met een veldmonster en analysemonster.

### Watermonster (met meerdere flessen)

- Veldmonster – ``WA1, matrix = GW     (MonsterType = 1)``			
    - Verpakking – ``Fles WA1-1, barcode: dfsfdslasd``				
    - Verpakking – ``Fles WA1-2, barcode: fdsvfdsvfs``				
    - Verpakking – ``Fles WA1-3, barcode: kjhgfvvxx``				
    - Verwijzing naar Analysemonster: ``WA1_Sample``
    - Veldmetingen ivm Observations
- Analysemonster – ``WA1_Sample, matrix = GW     (MonsterType = 10)``	
    - Verwijzing naar Veldmonster: ``WA1``
    - LabResultaten

## WBB_BBK_BOTOVA_v14.2.0.xml
In dit voorbeeldbestand zitten 3 watermonsters, verdeeld over 3 peilbuizen en 2 meetpunten.

Bij deze watermonsters zitten alle stoffen die normen hebben in BoToVa-service. Ze zijn handmatig verdeeld over de [analysemethode](https://codes.sikb.nl/0101/IMMetingen/Waardebepalingsmethode.xml)

Met Ids van de waardebepalingsmethode welke echt voorkomen in de database van een klant. Alleen mogelijk wel bij andere stoffen.

1 waardebepalingsmethode is nu nog vervallen, maar die zal weer geactiveerd worden: ‘Eigen methode’. Deze wordt heel veel gebruikt.
