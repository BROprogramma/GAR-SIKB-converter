<?xml version="1.0" encoding="utf-8"?>
<!-- XSLT for conversion of SIKB0101 to BRO GAR  
        SIKB0101 version: v14.2.0 
        IMMetingen version: v14.2.0 
        BRO GAR version: versie 0.9.9; release 20191114 
        Linda van den Brink @lvdbrink -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sikb="http://www.sikb.nl/imsikb0101" 
    xmlns:gar="http://www.broservices.nl/xsd/isgar/1.0" xmlns:brocom="http://www.broservices.nl/xsd/brocommon/3.0"
    xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:imm="http://www.sikb.nl/immetingen" 
    xmlns:garcom="http://www.broservices.nl/xsd/garcommon/1.0" xmlns:sam="http://www.opengis.net/sampling/2.0"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:spec="http://www.opengis.net/samplingSpecimen/2.0" 
    xmlns:om="http://www.opengis.net/om/2.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema" xsi:schemaLocation="http://www.sikb.nl/imsikb0101 imsikb0101_v14.2.0.xsd">
    
    <!-- extra namespace declarations, don't know if I need them yet 
        xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xdt="http://www.w3.org/2005/xpath-datatypes" 
    xmlns:imsikb0101="http://www.sikb.nl/imsikb0101" xmlns:immetingen="http://www.sikb.nl/immetingen" 
    xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gsr="http://www.isotc211.org/2005/gsr" xmlns:gss="http://www.isotc211.org/2005/gss" 
    xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:gml="http://www.opengis.net/gml/3.2"
    xmlns:sam="http://www.opengis.net/sampling/2.0"
    xmlns:sams="http://www.opengis.net/samplingSpatial/2.0" xmlns:spec="http://www.opengis.net/samplingSpecimen/2.0" 
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sikb="http://xslcontrole.sikb" 
    -->
    
    <!-- Issues
    - Rapportagegrens is op korte termijn niet te mappen. Dit betekent dat SIKB bestanden die getransformeerd worden naar GAR niet valide zijn. We moeten hiervoor een workaround 
   bedenken en implementeren in deze stylesheet 
    -  Afgesproken dat BRO nog wijzigingsverzoek indient voor het toevoegen van de inhoud van BRO bemonsteringsprocedure aan SIKB Bemonsteringsmethode.
    -  IM Metingen kent wel organisaties maar alleen namen terwijl de BRO KvKnummers opslaat. Ik moet nog uitzoeken of ik kvk nummers kan opzoeken in een aquo tabel. 
    - 'belucht' bij  SIKB = 'filter belucht' in de BRO. Zie issue: https://github.com/BROprogramma/GAR/issues/145.
    -  Specifiek BRO gerelateerde zaken zoals bronhouder, dataleverancier, kwaliteitsregime zijn bij IM Metingen niet bekend. Dergelijke gegevens zitten meestal in het bericht, 
    niet in het brondocument. Bronhouder: IMMetingen neemt bij organisaties een legalidentitynr op, nl het RSIN. Kvknr kan worden toegevoegd door of defintie van dit veld op 
    te rekken of een veld toe te voegen. Bij laboratorium als veld. Er is een organisatatie codelijst voor laboratoria (bij aquo-lex is dat wellicht beschikbaar incl kvk). 
    NIEUW
    - Geen mapping voor grondwatermonitoringnet.
   -->
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="sikb:FeatureCollectionIMSIKB0101">
        <gar:registrationRequest>
            <brocom:requestReference>[todo-mapping?]</brocom:requestReference>
            <!-- IMMetingen neemt bij organisaties een legalidentitynr op, nl het RSIN. Kvknr kan worden toegevoegd door of defintie van dit veld op 
    te rekken of een veld toe te voegen. Met het imskib0101:sender veld moet dus nog iets gebeuren. -->
            <brocom:deliveryAccountableParty><xsl:value-of select="sikb:metaData/sikb:sender"/></brocom:deliveryAccountableParty>
            <!-- assumption is that quality regime is always IMBRO (we are converting current data, not old data from some archive -->
            <brocom:qualityRegime>IMBRO</brocom:qualityRegime>
            <gar:sourceDocument>
                <xsl:apply-templates select="sikb:featureMember/sikb:Sample"/>
            </gar:sourceDocument>
        </gar:registrationRequest>
    </xsl:template>
            
    <xsl:template match="sikb:Sample">
        <gar:GAR>
            <xsl:apply-templates select="@gml:id"/>
            <gar:objectIdAccountableParty><xsl:value-of select="imm:identification/imm:NEN3610ID/imm:lokaalID"/></gar:objectIdAccountableParty>
            <gar:qualityControlMethod codeSpace="urn:bro:gar:QualityControlMethod">[todo: not in sikb sample file]<xsl:value-of select="sikb:correctnessJudgmentMethod"/></gar:qualityControlMethod>
            <!-- 1 or more repetitions: -->
            <gar:groundwaterMonitoringNet>[todo no mapping yet]</gar:groundwaterMonitoringNet>
            <monitoringPoint>
                <!-- finding the filter -->
                <xsl:for-each select="sam:relatedSamplingFeature/sam:SamplingFeatureComplex/sam:relatedSamplingFeature">
                    <xsl:apply-templates select="//sikb:Filter[@gml:id=substring-after(current()/@xlink:href, '#')]"/>
                </xsl:for-each>
            </monitoringPoint>
            <fieldResearch>
                <garcom:samplingDateTime><xsl:value-of select="imm:startTime"/></garcom:samplingDateTime>
                <!-- Optional: -->
                <garcom:samplingOperator>
                    <brocom:chamberOfCommerceNumber>[todo samplingOperator mapping, value of <xsl:value-of select="spec:processingDetails/imm:FieldSamplePreparationStep/spec:processOperator/local-name()"/>?]</brocom:chamberOfCommerceNumber>
                </garcom:samplingOperator>
                <garcom:samplingStandard codeSpace="urn:bro:gar:SamplingStandard">[todo not in sample file]</garcom:samplingStandard>
                <garcom:samplingDevice>
                    <garcom:pumpType codeSpace="urn:bro:gar:PumpType">[todo not in sample file]</garcom:pumpType>
                </garcom:samplingDevice>
                <xsl:text>[todo rest of fieldResearch]
                </xsl:text>
                <!-- hier gebleven. Verder kom ik nog niet met Veldonderzoek want in het voorbeeld zit geen MeasureResult.
                  Template maken voor MeasureResult. 
                <garcom:fieldObservation>
                    <garcom:primaryColour codeSpace="urn:bro:gar:Colour">[todo]</garcom:primaryColour>
                    <garcom:secondaryColour codeSpace="urn:bro:gar:Colour">[todo]</garcom:secondaryColour>
                    <garcom:colourStrength codeSpace="urn:bro:gar:ColourStrength">[todo]</garcom:colourStrength>
                    <garcom:abnormalityInCooling>[todo]</garcom:abnormalityInCooling>
                    <garcom:abnormalityInDevice>[todo]</garcom:abnormalityInDevice>
                    <garcom:pollutedByEngine>[todo]</garcom:pollutedByEngine>
                    <garcom:filterAerated>[todo]</garcom:filterAerated>
                    <garcom:groundWaterLevelDroppedTooMuch>[todo]</garcom:groundWaterLevelDroppedTooMuch>
                    <garcom:abnormalFilter>[todo]</garcom:abnormalFilter>
                    <garcom:sampleAerated>[todo]</garcom:sampleAerated>
                    <garcom:hoseReused>[todo]</garcom:hoseReused>
                    <garcom:temperatureDifficultToMeasure>[todo]</garcom:temperatureDifficultToMeasure>
                </garcom:fieldObservation>
                <garcom:fieldMeasurement>
                    <garcom:parameter>[todo]</garcom:parameter>
                    <garcom:fieldMeasurementValue uom="[todo]">[todo]</garcom:fieldMeasurementValue>
                    <garcom:qualityControlStatus codeSpace="urn:bro:gar:QualityControlStatus">[todo]</garcom:qualityControlStatus>
                </garcom:fieldMeasurement>-->
            </fieldResearch>
            
            <!-- create a gar:laboratoryAnalysis for each group of analysis done by the same lab. 
                The lab is found by going from analysis to procedure to processoperator.
                Issue: according to the mapping it should be measurementOrganisation instead of processOperator. -->
                
                <xsl:for-each-group select="/sikb:FeatureCollectionIMSIKB0101/sikb:featureMember/imm:Analysis" 
                    group-by="//imm:AnalysisProcess[@gml:id = substring-after(current()/om:procedure/@xlink:href, '#')]/imm:analysisOperator/@xlink:href">
                <gar:laboratoryAnalysis>
                    <xsl:variable name="analysis" select="."/>
                    <!-- issue: Time Period object is not in the sample file -->
                    <xsl:variable name="analysis-date" select="om:resultTime/@xlink:href"/>
                        <!-- fetch the id of responsibleLab:-->
                        <xsl:for-each select="//imm:AnalysisProcess[@gml:id = substring-after(current()/om:procedure/@xlink:href, '#')]">
                            <!-- fetch the responsibleLab info: -->
                            <xsl:for-each select="//imm:Organisation[@gml:id = substring-after(current()/imm:analysisOperator/@xlink:href, '#')]">
                                <garcom:responsibleLaboratory>
                                    <brocom:chamberOfCommerceNumber>[todo get kvknr from aquo codelist based on id: <xsl:value-of select="@gml:id"/>]</brocom:chamberOfCommerceNumber>
                                    <!-- You have a CHOICE of the next 2 items at this level
                        <brocom:chamberOfCommerceNumber>?</brocom:chamberOfCommerceNumber>
                         if no kvk (how to determine this?) then use this:
                        <brocom:europeanCompanyRegistrationNumber>?</brocom:europeanCompanyRegistrationNumber>
                       <brocom:europeanCompanyRegistrationNumber>DER2507_R2</brocom:europeanCompanyRegistrationNumber> -->
                                </garcom:responsibleLaboratory>
                            </xsl:for-each>
                            <!-- create a garcom:analysisProcess for each group of analysis done with the same method -->
                            <garcom:analysisProcess>
                                <garcom:analysisDate>
                                <!-- mapped to enddate of analysis - since they are grouped by method they should all be done at the same time we assume -->
                                    <brocom:date>[todo find linked TimePeriod by id: <xsl:value-of select="$analysis-date"/></brocom:date>
                                </garcom:analysisDate>
                                <!-- probably need to get the aquo code based on the SIKB id stored in the SIKB0101 file -->
                                <garcom:analyticalTechnique codeSpace="urn:bro:gar:AnalyticalTechnique"><xsl:value-of select="substring-after(imm:analyticalTechnique, 'id:')"/></garcom:analyticalTechnique>
                                <garcom:valuationMethod codeSpace="urn:bro:gar:ValuationMethod"><xsl:value-of select="substring-after(imm:valuationMethod, 'id:')"/></garcom:valuationMethod>
                                <!-- 1 or more analyses: -->
                                <!-- issue: don't know yet if this works if there are multiple analyses -->
                                <xsl:apply-templates select="$analysis"/>
                            </garcom:analysisProcess>
                        </xsl:for-each>
                </gar:laboratoryAnalysis>
            </xsl:for-each-group>
        </gar:GAR>
    </xsl:template>
    
    <xsl:template match="sikb:Filter">
        <garcom:GroundwaterMonitoringTube>
            <xsl:apply-templates select="@gml:id"/>
            <garcom:broId>[todo get BRO GMW ID based on??]</garcom:broId>
            <garcom:tubeNumber>[todo get BRO GMW tube number based on??]</garcom:tubeNumber>
        </garcom:GroundwaterMonitoringTube>
    </xsl:template>
    
    <xsl:template match="imm:Analysis">        
        <garcom:analysis>
            <garcom:parameter><xsl:value-of select="substring-after(imm:physicalProperty/imm:PhysicalProperty/imm:parameter, 'id:')"/></garcom:parameter>
            <xsl:apply-templates select="om:result"/>
        </garcom:analysis>
      </xsl:template>
    
    <xsl:template match="om:result">
        <garcom:analysisMeasurementValue uom="{concat('[todo get uom name from aquo codelist] ', imm:numericValue/@uom)}"><xsl:value-of select="imm:numericValue"/></garcom:analysisMeasurementValue>
        <xsl:apply-templates select="imm:limitSymbol"/>
        <garcom:reportingLimit uom="mg/l">[todo no reportingLimit in sample file yet]</garcom:reportingLimit>
        <xsl:apply-templates select="imm:qualityIndicatorType"/>
    </xsl:template>
    
    <xsl:template match="imm:limitSymbol">
        <garcom:limitSymbol codeSpace="urn:bro:gar:LimitSymbol">
            <xsl:choose>
                <xsl:when test="'&lt;'">LT</xsl:when>
                <xsl:when test="'&gt;'">GT</xsl:when>
                <xsl:otherwise>error</xsl:otherwise>
            </xsl:choose>
        </garcom:limitSymbol>
    </xsl:template>
    
    <xsl:template match="imm:qualityIndicatorType">
        <garcom:qualityControlStatus codeSpace="urn:bro:gar:QualityControlStatus">
           <xsl:variable name="quality-indicator" select="substring-after(., 'id:')"/>
            <!-- nicer to build a lookup table for this, but for now a cwo is fine -->
            <xsl:choose>
                <xsl:when test="$quality-indicator='1'">afgekeurd</xsl:when>
                <xsl:when test="$quality-indicator='2'">goedgekeurd</xsl:when>
                <xsl:when test="$quality-indicator='3'">onbekend</xsl:when>
                <xsl:when test="$quality-indicator='4'">onbeslist</xsl:when>
                <xsl:otherwise>error unknown quality indicator value</xsl:otherwise>
            </xsl:choose>
        </garcom:qualityControlStatus>
    </xsl:template>
    
    <xsl:template match="@gml:id">
        <xsl:copy-of select="."/>        
    </xsl:template>
</xsl:stylesheet>