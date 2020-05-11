<?xml version="1.0" encoding="utf-8"?>
<!-- XSLT for conversion of SIKB0101 to BRO GAR  
        SIKB0101 version: v14.2.0 
        IMMetingen version: v14.2.0 
        BRO GAR version: versie 1.0 from https://schema.broservices.nl/xsd/isgar/1.0/ 
        Linda van den Brink @lvdbrink -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sikb="http://www.sikb.nl/imsikb0101" xmlns:gar="http://www.broservices.nl/xsd/isgar/1.0"
    xmlns:brocom="http://www.broservices.nl/xsd/brocommon/3.0"
    xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:imm="http://www.sikb.nl/immetingen"
    xmlns:garcom="http://www.broservices.nl/xsd/garcommon/1.0"
    xmlns:sam="http://www.opengis.net/sampling/2.0" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:spec="http://www.opengis.net/samplingSpecimen/2.0"
    xmlns:om="http://www.opengis.net/om/2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema"
    xsi:schemaLocation="http://www.sikb.nl/imsikb0101 imsikb0101_v14.2.0.xsd">

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
    - Rapportagegrens is op korte termijn niet te mappen, dit gegeven wordt nu niet uitgewisseld via SIKB en niet vastgelegd in de praktijk. Wel de detectiegrens, maar dit is wat anders. In BRO GAR is dit gegeven optioneel. In deze stylesheet dus geen mapping voor rapportagegrens. 
    -  Afgesproken dat BRO nog wijzigingsverzoek indient voor het toevoegen van de inhoud van BRO bemonsteringsprocedure aan SIKB Bemonsteringsmethode.
    -  IM Metingen kent wel organisaties maar alleen namen terwijl de BRO KvKnummers opslaat. Kvknummer wordt bij organisatie toegevoegd aan IMMetingen. In voorbeeldbestand vast toevoegen, mogelijk wordt de naam van het element nog anders.
    - 'belucht' bij  SIKB = 'filter belucht' in de BRO. Zie issue: https://github.com/BROprogramma/GAR/issues/145.
    -  Specifiek BRO gerelateerde zaken zoals bronhouder, dataleverancier, kwaliteitsregime zijn bij IM Metingen niet bekend. Dergelijke gegevens zitten meestal in het bericht, 
    niet in het brondocument. Bronhouder: IMMetingen neemt bij organisaties een legalidentitynr op, nl het RSIN. Kvknr wordt toegevoegd door een veld toe te voegen aan organisatie.  
    NIEUW
    - Geen mapping voor grondwatermonitoringnet. Workaround: de stylesheet vult een dummy GMN code in. Op langere termijn is het de bedoeling dat gmn id aan SIKB wordt toegevoegd.
    - Nog niet mogelijk om put ID en buisnummer uit bron te halen. Workaround: dummy ID en nummer. Op langere termijn is het de bedoeling dat ofwel put BRO-ID en buisnummer aan SIKB worden toegevoegd, ofwel op te halen zijn via een service op basis van het in SIBK uitgewisselde gml:id van het filter.  
   -->

    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="sikb:FeatureCollectionIMSIKB0101">
        <gar:registrationRequest>
            <brocom:requestReference>[todo-mapping?]</brocom:requestReference>
            <!-- IMMetingen neemt bij organisaties een legalidentitynr op, nl het RSIN. Kvknr kan worden toegevoegd door of defintie van dit veld op 
    te rekken of een veld toe te voegen. Met het imskib0101:sender veld moet dus nog iets gebeuren. -->
            <brocom:deliveryAccountableParty>
                <xsl:value-of select="sikb:metaData/sikb:sender"/>
            </brocom:deliveryAccountableParty>
            <!-- assumption is that quality regime is always IMBRO (we are converting current data, not old data from some archive -->
            <brocom:qualityRegime>IMBRO</brocom:qualityRegime>
            <gar:sourceDocument>
                <!-- grouping the samples based on the related filter (role 7 indicates related filter) -->
                <xsl:for-each-group select="sikb:featureMember/sikb:Sample"
                    group-by="sam:relatedSamplingFeature/sam:SamplingFeatureComplex[substring-after(sam:role/@xlink:href, 'id:') = '7']/sam:relatedSamplingFeature/@xlink:href">
                    <gar:GAR>
                        <xsl:apply-templates select="."/>
                    </gar:GAR>
                </xsl:for-each-group>
            </gar:sourceDocument>
        </gar:registrationRequest>
    </xsl:template>

    <!-- because of the grouping earlier this template fires only once for each group of samples related to the same filter -->
    <xsl:template match="sikb:Sample">
        <!-- finding the related GMW by looking up the related sampling feature, the filter -->
        <xsl:variable name="sikb-borehole-id"
            select="substring-after(sam:relatedSamplingFeature/sam:SamplingFeatureComplex[substring-after(sam:role/@xlink:href, 'id:') = '6']/sam:relatedSamplingFeature/@xlink:href, '#')"/>
        <xsl:variable name="sikb-filter-id"
            select="substring-after(sam:relatedSamplingFeature/sam:SamplingFeatureComplex[substring-after(sam:role/@xlink:href, 'id:') = '7']/sam:relatedSamplingFeature/@xlink:href, '#')"/>
        <xsl:apply-templates select="@gml:id"/>
        <gar:objectIdAccountableParty>
            <xsl:value-of select="imm:identification/imm:NEN3610ID/imm:lokaalID"/>
        </gar:objectIdAccountableParty>
        <gar:qualityControlMethod codeSpace="urn:bro:gar:QualityControlMethod">[todo: not in sikb
            sample file]<xsl:value-of select="sikb:correctnessJudgmentMethod"
            /></gar:qualityControlMethod>
        <!-- dummy GMN ID until GMN BRO-id is added to SIKB0101 -->
        <gar:groundwaterMonitoringNet>
            <garcom:GroundwaterMonitoringNet gml:id="GMN123456789012">
                <garcom:broId>GMN123456789012</garcom:broId>
            </garcom:GroundwaterMonitoringNet>
        </gar:groundwaterMonitoringNet>
        <!-- finding the related GMW -->
        <gar:monitoringPoint>
            <garcom:GroundwaterMonitoringTube gml:id="{$sikb-borehole-id}">
                <!-- [todo get BRO GMW ID and tube number based on their sikb id] -->
                <xsl:comment>
                    $sikb-borehole-id = <xsl:value-of select="$sikb-borehole-id"/> 
                    $sikb-filter-id = <xsl:value-of select="$sikb-filter-id"/></xsl:comment>
                <garcom:broId>GMW012345678901</garcom:broId>
                <garcom:tubeNumber>1</garcom:tubeNumber>
            </garcom:GroundwaterMonitoringTube>
        </gar:monitoringPoint>
        <fieldResearch>
            <garcom:samplingDateTime>
                <xsl:value-of select="imm:startTime"/>
            </garcom:samplingDateTime>
            <!-- Optional: -->
            <garcom:samplingOperator>
                <brocom:chamberOfCommerceNumber>[todo samplingOperator mapping, no sampling
                    organisation in source]</brocom:chamberOfCommerceNumber>
            </garcom:samplingOperator>
            <garcom:samplingStandard codeSpace="urn:bro:gar:SamplingStandard">[todo not in sample
                file]</garcom:samplingStandard>
            <garcom:samplingDevice>
                <garcom:pumpType codeSpace="urn:bro:gar:PumpType">[todo not in sample
                    file]</garcom:pumpType>
            </garcom:samplingDevice>
            <xsl:comment>[todo rest of fieldResearch, no Characteristics in sample file]
                </xsl:comment>
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
        <!-- group the relatedobservations by valuationMethod, assuming it's always the same lab in the source data (otherwise we need to group by lab first) -->
       
        <gar:laboratoryAnalysis>
            <!-- fetch the responsibleLab info. Always the same lab, so just fetch the first one from the file-->
            <garcom:responsibleLaboratory>
                <brocom:chamberOfCommerceNumber>[todo mapping based on id:]<xsl:value-of select="/sikb:FeatureCollectionIMSIKB0101/sikb:featureMember/imm:AnalysisProcess[not(preceding::imm:AnalysisProcess)]/imm:measurementOrganisation"/>
                </brocom:chamberOfCommerceNumber>
            </garcom:responsibleLaboratory>
            <!-- fetch the observations, grouped by procedure -->
        <xsl:for-each select="sam:relatedObservation">
            <!--<debug> werkt, kan weg <xsl:value-of select="/sikb:FeatureCollectionIMSIKB0101/sikb:featureMember/imm:Analysis[@gml:id = substring-after(current()/@xlink:href, '#')]/om:procedure/@xlink:href"/></debug>-->
            <xsl:for-each-group select="/sikb:FeatureCollectionIMSIKB0101/sikb:featureMember/imm:Analysis[@gml:id = substring-after(current()/@xlink:href, '#')]"
                group-by="om:procedure/@xlink:href">
                <xsl:comment>distinct-values(//om:procedure/@xlink:href)</xsl:comment>
                <xsl:variable name="analysis" select="."/>
                <xsl:variable name="procedure" select="/sikb:FeatureCollectionIMSIKB0101/sikb:featureMember/imm:AnalysisProcess[@gml:id = substring-after(current()/om:procedure/@xlink:href, '#')]"/>
                <!--
                <xsl:comment><xsl:copy-of select="$analysis"/></xsl:comment>-->
                <!-- analysis date is just one of the result times from the group -->
                <xsl:variable name="analysis-date">
                    <xsl:choose>
                        <xsl:when test="om:resultTime/@xlink:href"><xsl:value-of select="//gml:TimeInstant[@gml:id = substring-after(om:resultTime/@xlink:href, '#')]/gml:timePosition"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="om:resultTime/gml:TimeInstant/gml:timePosition"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                    <!-- create a garcom:analysisProcess for each group of analysis done with the same method -->
                <!-- id added for debug reasons -->
                    <garcom:analysisProcess id="{$procedure/@gml:id}">
                        <garcom:analysisDate>
                            <!-- mapped to enddate of analysis - since they are grouped by method they should all be done at the same time we assume -->
                            <brocom:date><xsl:value-of select="$analysis-date"/></brocom:date>
                        </garcom:analysisDate>
                        <!-- probably need to get the aquo code based on the SIKB id stored in the SIKB0101 file -->
                        <garcom:analyticalTechnique codeSpace="urn:bro:gar:AnalyticalTechnique">
                            <xsl:value-of select="substring-after(imm:analyticalTechnique, 'id:')"/>
                        </garcom:analyticalTechnique>
                        <garcom:valuationMethod codeSpace="urn:bro:gar:ValuationMethod">
                            <xsl:value-of select="substring-after(imm:valuationMethod, 'id:')"/>
                        </garcom:valuationMethod>
                        <!-- 1 or more analyses: -->
                        <!-- issue: don't know yet if this works if there are multiple analyses -->
                        <xsl:apply-templates select="$analysis"/>
                    </garcom:analysisProcess>
                    <!--</xsl:for-each>-->
                
            </xsl:for-each-group>

        </xsl:for-each>
        </gar:laboratoryAnalysis>
    </xsl:template>

    <xsl:template match="imm:Analysis">
        <garcom:analysis>
            <garcom:parameter>
                <xsl:value-of
                    select="substring-after(imm:physicalProperty/imm:PhysicalProperty/imm:parameter, 'id:')"
                />
            </garcom:parameter>
            <xsl:apply-templates select="om:result"/>
        </garcom:analysis>
    </xsl:template>

    <xsl:template match="om:result">
        <garcom:analysisMeasurementValue
            uom="{concat('[todo get uom name from aquo codelist] ', imm:numericValue/@uom)}">
            <xsl:value-of select="imm:numericValue"/>
        </garcom:analysisMeasurementValue>
        <xsl:apply-templates select="imm:limitSymbol"/>
        <garcom:reportingLimit uom="mg/l">[todo no reportingLimit in sample file
            yet]</garcom:reportingLimit>
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
                <xsl:when test="$quality-indicator = '1'">afgekeurd</xsl:when>
                <xsl:when test="$quality-indicator = '2'">goedgekeurd</xsl:when>
                <xsl:when test="$quality-indicator = '3'">onbekend</xsl:when>
                <xsl:when test="$quality-indicator = '4'">onbeslist</xsl:when>
                <xsl:otherwise>error unknown quality indicator value</xsl:otherwise>
            </xsl:choose>
        </garcom:qualityControlStatus>
    </xsl:template>

    <xsl:template match="@gml:id">
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>
