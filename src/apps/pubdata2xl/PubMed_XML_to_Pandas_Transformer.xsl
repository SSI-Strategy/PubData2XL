<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" encoding="utf-8" indent="yes"/>

  <!-- This escapes rich text inside abstracts, titles and other texts. -->
  <xsl:template match="b|i|sup|sub|u|DispFormula|*[starts-with(name(), 'mml')]">
    <xsl:text>{--</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>--}</xsl:text>
    <xsl:apply-templates select="node()|@*"/>
    <xsl:text>{--/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>--}</xsl:text>
  </xsl:template>
  <!-- This match serves as substite for copy-of and also applies <b> <i>, <sup>, <etc> above -->
  <xsl:template match="VolumeTitle|ArticleTitle|VernacularTitle|CoiStatement|
  PMID|Language|Publisher/PublisherName|Publisher/PublisherLocation|
  Volume|NumberOfReferences|CitationSubset|MedlineTA|NlmUniqueID|ISSNLinking|
  ISOAbbreviation|JournalIssue/Volume|JournalIssue/Issue|CopyrightInformation|
  PublicationStatus|LocationLabel|Keyword|Citation">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="node()" />
    </xsl:element>
  </xsl:template>
  
  <!-- Starts Here -->
  <xsl:template match="PubmedArticleSet|BookDocumentSet">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="PubmedArticle | PubmedBookArticle | BookDocument">
    <xsl:element name="Citation">
      <xsl:element name="Order">
          <xsl:number count="PubmedArticle | PubmedBookArticle" from="PubmedArticleSet" level="any"/>
      </xsl:element>
      <xsl:apply-templates select="MedlineCitation"/>
      <xsl:apply-templates select="PubmedData"/>
      <xsl:apply-templates select="BookDocument"/>
      <xsl:apply-templates select="PubmedBookData"/>
    </xsl:element>
  </xsl:template>

  <!-- BookDocument -->
  <xsl:template match="BookDocument">
    <xsl:element name="Type">PubmedBookArticle</xsl:element>
    <xsl:apply-templates select="PMID"/>
    <xsl:apply-templates select="ArticleIdList"/>
    <xsl:apply-templates select="Book"/>
    <xsl:apply-templates select="LocationLabel"/>
    <xsl:element name="LocationLabel_Type">
      <xsl:value-of select='LocationLabel/@Type'/>
    </xsl:element>
    <xsl:apply-templates select="ArticleTitle"/>
    <xsl:apply-templates select="VernacularTitle"/>
    <xsl:apply-templates select="Pagination"/>
    <xsl:apply-templates select="Language"/>
    <xsl:apply-templates select="AuthorList"/>
    <xsl:apply-templates select="InvestigatorList"/>
    <xsl:element name="PublicationTypeList_all_data">
      <xsl:apply-templates select="PublicationType" mode="all_data"/>
    </xsl:element>
    <xsl:element name="PublicationTypeList">
      <xsl:apply-templates select="PublicationType" mode="clean"/>
    </xsl:element>
    <xsl:apply-templates select="Abstract"/>
    <xsl:apply-templates select="Sections"/>
    <xsl:apply-templates select="KeywordList"/>
    <xsl:apply-templates select="ContributionDate"/>
    <xsl:apply-templates select="DateRevised"/>
    <xsl:apply-templates select="GrantList"/>
    <xsl:apply-templates select="ItemList"/>
    <xsl:apply-templates select="ReferenceList"/>
  </xsl:template>
  <!-- End BookDocument -->

  <xsl:template match="Book">
    <xsl:apply-templates select="Publisher/PublisherName"/>
    <xsl:apply-templates select="Publisher/PublisherLocation"/>
    <xsl:apply-templates select="BookTitle"/>
    <xsl:apply-templates select="PubDate"/>
    <xsl:apply-templates select="AuthorList"/>
    <xsl:apply-templates select="InvestigatorList"/>
    <xsl:apply-templates select="Volume"/>
    <xsl:apply-templates select="VolumeTitle"/>
    <xsl:apply-templates select="CollectionTitle"/>
    <xsl:if test="Isbn != ''">
      <xsl:element name="Isbn">
        <xsl:for-each select="Isbn">
          <xsl:if test="position() != 1">||</xsl:if>
          <xsl:value-of select='text()'/>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
    <xsl:if test="ELocationID != ''">
      <xsl:element name="ELocationID">
        <xsl:for-each select="ELocationID">
          <xsl:if test="position() != 1">||</xsl:if>
          <xsl:value-of select='concat( @EIdType,": ", text())'/>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>    
  </xsl:template>

  <xsl:template match="ItemList">
    <xsl:variable name="ItemList_Type"><xsl:value-of select='@ListType'/></xsl:variable>
    <xsl:element name="ItemList_{$ItemList_Type}">
        <xsl:for-each select="Item">
          <xsl:if test="position() != 1">||</xsl:if>
          <xsl:value-of select='text()'/>
        </xsl:for-each>
      </xsl:element>
  </xsl:template>

  <xsl:template match="Sections">
    <xsl:element name="Sections">
        <xsl:for-each select="Section">
          <xsl:if test="position() != 1">||</xsl:if>
          <xsl:variable name="SectionTitle"><xsl:apply-templates select="SectionTitle" /></xsl:variable>
          <xsl:variable name="LocationLabel_Type"><xsl:if test="LocationLabel/@Type != ''"><xsl:text>, LocationLabel Type: </xsl:text><xsl:value-of select='LocationLabel/@Type'/></xsl:if></xsl:variable>
          <xsl:variable name="LocationLabel"><xsl:if test="LocationLabel != ''"><xsl:text>, LocationLabel: </xsl:text><xsl:value-of select='LocationLabel'/></xsl:if></xsl:variable>
          <xsl:value-of select='concat("Section: ", $SectionTitle, $LocationLabel, $LocationLabel_Type)'/>
        </xsl:for-each>
      </xsl:element>
  </xsl:template>

  <xsl:template match="SectionTitle">
    <xsl:apply-templates select="node()" />
    <xsl:if test="@book != ''">
      <xsl:value-of select='concat(", BookID: ", @book)'/>
    </xsl:if>
    <xsl:if test="@sec != ''">
      <xsl:value-of select='concat(", BookSectionID: ", @sec)'/>
    </xsl:if>    
    <xsl:if test="@part != ''">
      <xsl:value-of select='concat(", BookPartID: ", @part)'/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="BookTitle|CollectionTitle">
    <xsl:element name="{name()}">
      <xsl:apply-templates select="node()" />
    </xsl:element>
    <xsl:if test="@book != ''">
      <xsl:element name="BookID">
        <xsl:value-of select='@book'/>
      </xsl:element>
    </xsl:if>
    <xsl:if test="@sec != ''">
      <xsl:element name="BookSectionID">
        <xsl:value-of select='@sec'/>
      </xsl:element>
    </xsl:if>    
    <xsl:if test="@part != ''">
      <xsl:element name="BookPartID">
        <xsl:value-of select='@part'/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  <!-- End Book -->

  <!-- MedlineCitation -->
  <xsl:template match="MedlineCitation">
    <xsl:element name="Type">PubmedArticle</xsl:element>
    <xsl:element name="Status">
      <xsl:value-of select="@Status"/>
    </xsl:element>
    <xsl:element name="IndexingMethod">
      <xsl:value-of select="@IndexingMethod"/>
    </xsl:element>
    <xsl:element name="Owner">
      <xsl:value-of select="@Owner"/>
    </xsl:element>
    <xsl:apply-templates select="PMID"/>
    <xsl:apply-templates select="DateCompleted"/>
    <xsl:apply-templates select="DateRevised"/>
    <xsl:apply-templates select="Article"/>
    <xsl:apply-templates select="MedlineJournalInfo"/>
    <xsl:apply-templates select="ChemicalList"/>
    <xsl:apply-templates select="SupplMeshList"/>
    <xsl:apply-templates select="CitationSubset"/>
    <xsl:apply-templates select="CommentsCorrectionsList"/>
    <xsl:apply-templates select="GeneSymbolList"/>
    <xsl:apply-templates select="MeshHeadingList"/>
    <xsl:apply-templates select="NumberOfReferences"/>
    <xsl:apply-templates select="PersonalNameSubjectList"/>
    <xsl:apply-templates select="OtherID"/>
    <xsl:apply-templates select="OtherAbstract"/>
    <xsl:apply-templates select="KeywordList"/>
    <xsl:apply-templates select="CoiStatement"/>
    <xsl:if test="SpaceFlightMission != ''">
      <xsl:element name="SpaceFlightMission">
        <xsl:for-each select="SpaceFlightMission">
          <xsl:if test="position() != 1">||</xsl:if>
          <xsl:value-of select='concat("SpaceFlightMission: ", text())'/>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
    <xsl:apply-templates select="InvestigatorList"/>
    <xsl:apply-templates select="GeneralNote"/>
  </xsl:template>

  <xsl:template match="Article">
    <xsl:element name="PubModel">
      <xsl:value-of select="@PubModel"/>
    </xsl:element>
    <xsl:apply-templates select="Journal"/>
    <xsl:apply-templates select="ArticleTitle"/>
    <xsl:apply-templates select="VernacularTitle"/>
    <xsl:apply-templates select="Pagination"/>
    <xsl:if test="ELocationID != ''">
      <xsl:element name="ELocationID">
        <xsl:for-each select="ELocationID">
          <xsl:if test="position() != 1">||</xsl:if>
          <xsl:value-of select='concat( @EIdType,": ", text())'/>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
    <xsl:apply-templates select="Abstract"/>
    <xsl:apply-templates select="AuthorList"/>
    <xsl:element name="Language">
      <xsl:for-each select="Language">
        <xsl:if test="position() != 1">||</xsl:if>
        <xsl:value-of select='text()'/>
      </xsl:for-each>
    </xsl:element>
    <xsl:apply-templates select="GrantList"/>
    <xsl:apply-templates select="PublicationTypeList"/>
    <xsl:apply-templates select="ArticleDate"/>
  </xsl:template>

  <xsl:template match="MedlineJournalInfo">
    <xsl:element name="Journal_Country">
      <xsl:value-of select='Country'/>
    </xsl:element>
    <xsl:apply-templates select="MedlineTA"/>
    <xsl:apply-templates select="NlmUniqueID"/>
    <xsl:apply-templates select="ISSNLinking"/>
  </xsl:template>

  <xsl:template match="Pagination">
    <xsl:element name="Pagination">
      <xsl:choose>
        <xsl:when test="MedlinePgn != ''">
          <xsl:value-of select="MedlinePgn"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="StartPage != ''">
              <xsl:value-of select="StartPage"/>
              <xsl:if test="EndPage != ''">
                <xsl:value-of select="concat('-', EndPage)"/>
              </xsl:if>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="Journal">
    <xsl:element name="JournalTitle"><xsl:value-of select="Title"/></xsl:element>
    <xsl:apply-templates select="ISOAbbreviation"/>
    <xsl:variable name="ISSN" select="concat('ISSN_', ISSN/@IssnType)"/>
    <xsl:element name='{$ISSN}'><xsl:value-of select="ISSN"/></xsl:element>
    <xsl:apply-templates select="JournalIssue/Volume"/>
    <xsl:apply-templates select="JournalIssue/Issue"/>
    <xsl:apply-templates select="JournalIssue/PubDate"/>
  </xsl:template>

  <xsl:template match="Abstract | OtherAbstract">
    <xsl:if test="@Type">
      <xsl:element name="{name(.)}_Type">
        <xsl:value-of select='@Type'/>
      </xsl:element>
    </xsl:if>
    <xsl:if test="@Language">
      <xsl:element name="{name(.)}_Language">
        <xsl:value-of select='@Language'/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="{name(.)}">
      <!-- <xsl:apply-templates select="@Type"/>
      <xsl:apply-templates select="@Language"/> -->
      <xsl:for-each select="AbstractText">
        <xsl:if test="@Label">
          <xsl:choose>
            <xsl:when test="position() = 1">
              <xsl:value-of select='concat(@Label,": ")'/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select='concat(" \n ", @Label,": ")'/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:apply-templates select="node()" />
      </xsl:for-each>
    </xsl:element>
    <xsl:apply-templates select="CopyrightInformation"/>
  </xsl:template>

  <!-- All Date type fields -->
  <xsl:template match="DateCompleted | DateRevised | PubDate | ArticleDate | PubMedPubDate | ContributionDate">
    <xsl:variable name="date_element"><xsl:value-of select ="name(.)"/><xsl:if test="@PubStatus != ''"><xsl:value-of select ="concat('_', @PubStatus)"/></xsl:if></xsl:variable>
    <xsl:variable name="date_type"><xsl:if test="@DateType != ''"><xsl:value-of select ="concat('_', @DateType)"/></xsl:if></xsl:variable>
    <xsl:variable name="Year"><xsl:if test="Year != ''"><xsl:value-of select ="Year"/></xsl:if></xsl:variable>
    <xsl:variable name="Month">
      <xsl:if test="Month != ''">
        <xsl:choose>
          <xsl:when test="string-length(Month) = 1 and number(Month) >= 1 and number(Month) &lt;= 9">
            <xsl:value-of select ="concat('-0', Month)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select ="concat('-', Month)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="Day">
      <xsl:if test="Day != ''">
        <xsl:choose>
          <xsl:when test="string-length(Day) = 1 and number(Day) >= 1 and number(Day) &lt;= 9">
            <xsl:value-of select ="concat('-0', Day)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select ="concat('-', Day)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="Hour">
      <xsl:if test="Hour != ''">
        <xsl:choose>
          <xsl:when test="string-length(Hour) = 1 and number(Hour) >= 0 and number(Hour) &lt;= 9">
            <xsl:value-of select ="concat(' 0', Hour)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select ="concat(' ', Hour)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="Minute">
      <xsl:if test="Minute != ''">
        <xsl:choose>
          <xsl:when test="string-length(Minute) = 1 and number(Minute) >= 0 and number(Minute) &lt;= 9">
            <xsl:value-of select ="concat(':0', Minute)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select ="concat(':', Minute)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="Second">
      <xsl:if test="Second != ''">
        <xsl:choose>
          <xsl:when test="string-length(Second) = 1 and number(Second) >= 0 and number(Second) &lt;= 9">
            <xsl:value-of select ="concat(':0', Second)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select ="concat(':', Second)"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select ="concat(':', Second)"/>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="Season"><xsl:if test="Season != ''"><xsl:value-of select ="concat('-', Season)"/></xsl:if></xsl:variable>
    
    <xsl:element name="{concat($date_element, $date_type)}">
      <xsl:value-of select ="concat($Year, $Month, $Day, $Season, $Hour, $Minute, $Second)"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Author | Investigator | PersonalNameSubject" mode="all_data">
    <xsl:variable name="CollectiveName"><xsl:if test="CollectiveName != ''"><xsl:text>, CollectiveName: </xsl:text><xsl:apply-templates select="CollectiveName" /></xsl:if></xsl:variable>
    <xsl:variable name="LastName"><xsl:if test="LastName != ''"><xsl:value-of select ='concat(", LastName: ", LastName)'/></xsl:if></xsl:variable>
    <xsl:variable name="ForeName"><xsl:if test="ForeName != ''"><xsl:value-of select ='concat(", ForeName: ", ForeName)'/></xsl:if></xsl:variable>
    <xsl:variable name="Initials"><xsl:if test="Initials != ''"><xsl:value-of select ='concat(", Initials: ", Initials)'/></xsl:if></xsl:variable>
    <xsl:variable name="Suffix"><xsl:if test="Suffix != ''"><xsl:text>, Suffix: </xsl:text><xsl:apply-templates select="Suffix" /></xsl:if></xsl:variable>
    <xsl:variable name="Identifier"><xsl:if test="Identifier != ''"><xsl:value-of select ='concat(", ", Identifier/@Source, ": ", Identifier, " ")'/></xsl:if></xsl:variable>
    <xsl:variable name="AffiliationInfo">
      <xsl:if test="not(CollectiveName)">
        <xsl:if test="not(AffiliationInfo)">, Affiliation: Not Available</xsl:if>
        <xsl:for-each select="AffiliationInfo">
          <xsl:variable name="Affiliation"><xsl:apply-templates select="node()" /></xsl:variable>
          <xsl:value-of select ='concat(", Affiliation ", position(), ": ", $Affiliation)'/>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat("Position: ", position(), $CollectiveName, $LastName, $ForeName, $Initials, $Suffix, $Identifier, $AffiliationInfo)'/>
  </xsl:template>

   <xsl:template match="Author | Investigator | PersonalNameSubject" mode="fullnames">
    <xsl:variable name="CollectiveName" select="CollectiveName"/>
    <xsl:variable name="LastName" select ='LastName'/>
    <xsl:variable name="ForeName"><xsl:if test="ForeName != ''"><xsl:value-of select ='concat(", ", ForeName)'/></xsl:if></xsl:variable>
    <xsl:variable name="Suffix"><xsl:if test="Suffix != ''"><xsl:text> </xsl:text><xsl:apply-templates select="Suffix" /></xsl:if></xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($CollectiveName, $LastName, $ForeName, $Suffix)'/>
  </xsl:template>

  <xsl:template match="Author | Investigator | PersonalNameSubject" mode="name_first">
    <xsl:variable name="CollectiveName" select="CollectiveName"/>
    <xsl:variable name="ForeName"><xsl:if test="ForeName != ''"><xsl:value-of select ='concat(ForeName, " ")'/></xsl:if></xsl:variable>
    <xsl:variable name="LastName" select ='LastName'/>
    <xsl:variable name="Suffix"><xsl:if test="Suffix != ''"><xsl:text> </xsl:text><xsl:apply-templates select="Suffix" /></xsl:if></xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($CollectiveName, $ForeName, $LastName, $Suffix)'/>
  </xsl:template>

  <xsl:template match="Author | Investigator | PersonalNameSubject" mode="fullnames_with_affiliation">
    <xsl:variable name="CollectiveName" select="CollectiveName"/>
    <xsl:variable name="LastName" select ='LastName'/>
    <xsl:variable name="ForeName"><xsl:if test="ForeName != ''"><xsl:value-of select ='concat(", ", ForeName)'/></xsl:if></xsl:variable>
    <xsl:variable name="Suffix"><xsl:if test="Suffix != ''"><xsl:text> </xsl:text><xsl:apply-templates select="Suffix" /></xsl:if></xsl:variable>
    <xsl:variable name="AffiliationInfo">
      <xsl:if test="not(CollectiveName)">
        <xsl:text> (</xsl:text>
        <xsl:if test="not(AffiliationInfo)">Affiliation: Not Available</xsl:if>
        <xsl:for-each select="AffiliationInfo">
          <xsl:if test="position() != 1">, </xsl:if>
          <xsl:variable name="Affiliation"><xsl:apply-templates select="node()" /></xsl:variable>
          <xsl:value-of select ='concat("Affiliation ", position(), ": ", $Affiliation)'/>
        </xsl:for-each>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($CollectiveName, $LastName, $ForeName, $Suffix, $AffiliationInfo)'/>
  </xsl:template>

  <xsl:template match="Author | Investigator | PersonalNameSubject" mode="abbreviated">
    <xsl:variable name="CollectiveName" select="CollectiveName"/>
    <xsl:variable name="LastName" select ='LastName'/>
    <xsl:variable name="Initials"><xsl:if test="Initials != ''"><xsl:value-of select ='concat(" ", Initials)'/></xsl:if></xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($CollectiveName, $LastName, $Initials)'/>
  </xsl:template>

  <xsl:template match="AuthorList | InvestigatorList | PersonalNameSubjectList">
    <xsl:variable name="listname">
      <xsl:choose>
        <xsl:when test="@Type = 'authors'">AuthorList</xsl:when>
        <xsl:when test="@Type = 'editors'">EditorList</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select ='name(.)'/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$listname}">
      <xsl:apply-templates select="Author | Investigator | PersonalNameSubject" mode="all_data"/>
    </xsl:element>
    <xsl:element name="{concat($listname, '_Fullnames')}">
      <xsl:apply-templates select="Author | Investigator | PersonalNameSubject" mode="fullnames"/>
    </xsl:element>
    <xsl:element name="{concat($listname, '_Name_First')}">
      <xsl:apply-templates select="Author | Investigator | PersonalNameSubject" mode="name_first"/>
    </xsl:element>
    <xsl:element name="{concat($listname, '_Fullnames_with_affiliation')}">
      <xsl:apply-templates select="Author | Investigator | PersonalNameSubject" mode="fullnames_with_affiliation"/>
    </xsl:element>
    <xsl:element name="{concat($listname, '_Abbreviated')}">
      <xsl:apply-templates select="Author | Investigator | PersonalNameSubject" mode="abbreviated"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Grant" mode="all_data">
    <xsl:variable name="GrantID"><xsl:if test="GrantID != ''"><xsl:value-of select ='concat(", GrantID: ", GrantID)'/></xsl:if></xsl:variable>
    <xsl:variable name="Acronym"><xsl:if test="Acronym != ''"><xsl:value-of select ='concat(", Acronym: ", Acronym)'/></xsl:if></xsl:variable>
    <xsl:variable name="Agency"><xsl:if test="Agency != ''"><xsl:value-of select ='concat(", Agency: ", Agency)'/></xsl:if></xsl:variable>
    <xsl:variable name="Country"><xsl:if test="Country != ''"><xsl:value-of select ='concat(", Country: ", Country)'/></xsl:if></xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat("Position: ", position(), $GrantID, $Acronym, $Agency, $Country)'/>
  </xsl:template>

  <xsl:template match="Grant" mode="clean">
    <xsl:variable name="GrantID" select ='GrantID'/>
    <xsl:variable name="Acronym"><xsl:if test="Acronym != ''"><xsl:value-of select ='concat(", ", Acronym)'/></xsl:if></xsl:variable>
    <xsl:variable name="Agency"><xsl:if test="Agency != ''"><xsl:value-of select ='concat(", ", Agency)'/></xsl:if></xsl:variable>
    <xsl:variable name="Country"><xsl:if test="Country != ''"><xsl:value-of select ='concat(", ", Country)'/></xsl:if></xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($GrantID, $Acronym, $Agency, $Country)'/>
  </xsl:template>

  <xsl:template match="GrantList">
    <xsl:element name="GrantList_all_data">
      <xsl:apply-templates select="Grant" mode="all_data"/>
    </xsl:element>
    <xsl:element name="GrantList">
      <xsl:apply-templates select="Grant" mode="clean"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="PublicationType" mode="all_data">
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat("PublicationType: ", text(), ", UI: ", @UI)'/>
  </xsl:template>
  
  <xsl:template match="PublicationType" mode="clean">
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='text()'/>
  </xsl:template>

  <xsl:template match="PublicationTypeList">
    <xsl:element name="PublicationTypeList_all_data">
      <xsl:apply-templates select="PublicationType" mode="all_data"/>
    </xsl:element>
    <xsl:element name="PublicationTypeList">
      <xsl:apply-templates select="PublicationType" mode="clean"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="MeshHeading" mode="all_data">
    <xsl:variable name="DescriptorName"><xsl:value-of select ='concat("DescriptorName: ", DescriptorName, ", UI: ", DescriptorName/@UI, ", MajorTopicYN: ", DescriptorName/@MajorTopicYN)'/></xsl:variable>
    <xsl:variable name="QualifierName">
      <xsl:for-each select="QualifierName">
        <xsl:if test="position() != 1">||<xsl:value-of select ='$DescriptorName'/></xsl:if>
        <xsl:value-of select ='concat(" / QualifierName: ", text(), ", UI: ", @UI, ", MajorTopicYN: ", @MajorTopicYN)'/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($DescriptorName, $QualifierName)'/>
  </xsl:template>

  <xsl:template match="MeshHeading" mode="clean">
    <xsl:variable name="DescriptorName"><xsl:value-of select ='DescriptorName'/><xsl:if test="DescriptorName/@MajorTopicYN = 'Y'">*</xsl:if></xsl:variable>
    <xsl:variable name="QualifierName">
      <xsl:for-each select="QualifierName">
        <xsl:if test="position() != 1">||<xsl:value-of select ='$DescriptorName'/></xsl:if>
        <xsl:value-of select ='concat(" / ", text())'/>
        <xsl:if test="@MajorTopicYN = 'Y'">*</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat($DescriptorName, $QualifierName)'/>
  </xsl:template>

  <xsl:template match="MeshHeadingList">
    <xsl:element name="MeshHeadingList">
      <xsl:apply-templates select="MeshHeading" mode="clean"/>
    </xsl:element>
    <xsl:element name="MeshHeadingList_all_data">
      <xsl:apply-templates select="MeshHeading" mode="all_data"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="SupplMeshList">
    <xsl:element name="SupplMeshList">
      <xsl:for-each select="SupplMeshName">
        <xsl:if test="position() != 1">||</xsl:if>
        <xsl:value-of select='concat("SupplMeshName: ", text(), ", UI: ", @UI, ", Type: ", @Type)'/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Keyword" mode="clean">
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:apply-templates select="node()" />
    <xsl:if test="@MajorTopicYN = 'Y'">*</xsl:if>
  </xsl:template>

  <xsl:template match="Keyword" mode="all_data">
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:variable name="Keyword"><xsl:apply-templates select="node()" /></xsl:variable>
    <xsl:value-of select='concat("Keyword: ", $Keyword, ", MajorTopicYN: ", @MajorTopicYN)'/>
  </xsl:template>

  <xsl:template match="KeywordList">
    <xsl:element name="KeywordList">
      <xsl:apply-templates select="Keyword" mode="clean"/>
    </xsl:element>
    <xsl:element name="KeywordList_all_data">
      <xsl:apply-templates select="Keyword" mode="all_data"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="OtherID">
    <xsl:element name="OtherID">
      <xsl:value-of select ='concat("OtherID: ", text(), ", Source: ", @Source)'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="GeneralNote">
    <xsl:element name="GeneralNote">
      <xsl:value-of select='concat("Owner: ", @Owner,", GeneralNote: ", text())'/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="Chemical" mode="clean">
    <xsl:variable name="NameOfSubstance" select="NameOfSubstance/text()"/>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='$NameOfSubstance'/> 
  </xsl:template>

  <xsl:template match="Chemical" mode="all_data">
    <xsl:variable name="NameOfSubstance" select="NameOfSubstance/text()"/>
    <xsl:variable name="RegistryNumber" select="RegistryNumber"/>
    <xsl:variable name="UI" select="NameOfSubstance/@UI"/>
    <xsl:if test="position() != 1">||</xsl:if>
    <xsl:value-of select='concat("NameOfSubstance: ", $NameOfSubstance, ", RegistryNumber: ", $RegistryNumber, ", UI: ", $UI)'/> 
  </xsl:template>

  <xsl:template match="ChemicalList">
    <xsl:element name="ChemicalList">
      <xsl:apply-templates select="Chemical" mode="clean"/>
    </xsl:element>
    <xsl:element name="ChemicalList_all_data">
      <xsl:apply-templates select="Chemical" mode="all_data"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="CommentsCorrectionsList">
    <xsl:element name="CommentsCorrectionsList">
      <xsl:for-each select="CommentsCorrections">
        <xsl:if test="position() != 1">||</xsl:if>
        <xsl:value-of select='concat("RefType: ", @RefType, ", PMID: ", PMID, ", RefSource: ", RefSource/text())'/> 
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="GeneSymbolList">
    <xsl:element name="{name(.)}">
      <xsl:for-each select="GeneSymbol">
        <xsl:if test="position() != 1">||</xsl:if>
        <xsl:value-of select='concat("GeneSymbol: ", text())'/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  <!-- End MedlineCitation -->
  
  <!-- PubmedData -->
  <xsl:template match="PubmedData|PubmedBookData">
    <xsl:apply-templates select="History/PubMedPubDate"/>
    <xsl:apply-templates select="PublicationStatus"/>
    <xsl:element name='NLM_ArticleIdList'>
      <xsl:variable name="IdList"><xsl:apply-templates select="ArticleIdList"/></xsl:variable>
      <xsl:value-of select='$IdList'/>
    </xsl:element>
    <xsl:apply-templates select="ObjectList"/>
    <xsl:apply-templates select="ReferenceList"/>
  </xsl:template>

  <xsl:template match="ReferenceList">
    <xsl:element name="ReferenceList">
      <xsl:for-each select="Reference">
        <xsl:variable name="Citation"><xsl:apply-templates select="Citation"/></xsl:variable>
        <xsl:variable name="ArticleIdList"><xsl:apply-templates select="ArticleIdList"/></xsl:variable>
        <xsl:if test="position() != 1">||</xsl:if>
        <xsl:value-of select='concat($Citation, " ", $ArticleIdList)'/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ArticleIdList">
    <xsl:element name="ArticleIdList">
      <xsl:for-each select="ArticleId">
        <xsl:if test="position() != 1"><xsl:text>. </xsl:text></xsl:if>
        <xsl:value-of select='concat(@IdType, ": ", text())'/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>

  <xsl:template match="ObjectList">
    <xsl:element name="ObjectList">
      <xsl:for-each select="Object">
        <xsl:variable name="Params">
          <xsl:for-each select="Param">
            <xsl:if test="position() != 1">||</xsl:if>
            <xsl:apply-templates select="node()" />
          </xsl:for-each>
        </xsl:variable>
        <xsl:if test="position() != 1">||</xsl:if>
        <xsl:value-of select='concat(@Type, ": ", $Params)'/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  <!-- End PubmedData -->

</xsl:stylesheet>