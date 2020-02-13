# Uitleg voorbeeldbestanden

Wat zit er o.a. in?
- Project
- Meetpunten
    - Filters
    - Veldmonsters (water)
- Analysemonster (water)
    - AnalyseResultaat
        - Procedure

## Hoe werken veldmonster en analysemonster?

Dit is een voorbeeld hoe dat werkt.

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
