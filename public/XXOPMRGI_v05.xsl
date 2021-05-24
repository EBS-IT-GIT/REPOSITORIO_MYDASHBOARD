<?xml version="1.0" encoding="iso-8859-1"?>
<!-- $Header: XXBOMLM_XSL_01.xsl 115.2 2016/09/01 15:32:02 xdouser noship $ -->
<!-- dbdrv: none -->

<!DOCTYPE xsl:stylesheet [
 <!ENTITY newline "&amp;#10;">
]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns="urn:schemas-microsoft-com:office:spreadsheet" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet" xmlns:ora="http://www.oracle.com/XSL/Transform/java/" xmlns:xdofo="http://xmlns.oracle.com/oxp/fo/extensions" xmlns:xdoxslt="http://www.oracle.com/XSL/Transform/java/oracle.apps.xdo.template.rtf.XSLTFunctions" xmlns:xdoxliff="urn:oasis:names:tc:xliff:document:1.1" xmlns:xlink="http://www.w3.org/1999/xlink">
 <xsl:param name="_XDOCALENDAR">GREGORIAN</xsl:param>
 <xsl:param name="_XDOLOCALE">en-US</xsl:param>
 <xsl:param name="_XDOTIMEZONE">GMT</xsl:param>
 <xsl:param name="_XDODFOVERRIDE">;</xsl:param>
 <xsl:param name="_XDOCURMASKS">;</xsl:param>
 <xsl:param name="_XDOCHARTTYPE">image/svg+xml</xsl:param>
 <xsl:param name="_XDOOUTPUTFORMAT">application/pdf</xsl:param>
 <xsl:param name="_XDOSVGFONTEMBED">true</xsl:param>
 <xsl:param name="_XDOCTX">#</xsl:param>
 <xsl:variable name="_XDOXSLTCTX" select="xdoxslt:set_xslt_locale($_XDOCTX, $_XDOLOCALE, $_XDOTIMEZONE, $_XDOCALENDAR, concat($_XDODFOVERRIDE,'',$_XDOCURMASKS))"/>
 <xsl:variable name="_XDOFOPOS" select="''"/>
 <xsl:variable name="_XDOFOPOS2" select="number(1)"/>
 <xsl:variable name="_XDOFOTOTAL" select="number(1)"/>
 <xsl:variable name="_XDOFOOSTOTAL" select="number(0)"/>
 <xsl:template match="/">
  <xsl:processing-instruction name="mso-application">
   <xsl:text>progid="Excel.Sheet"</xsl:text>
  </xsl:processing-instruction>
<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:o="urn:schemas-microsoft-com:office:office"
 xmlns:x="urn:schemas-microsoft-com:office:excel"
 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
 xmlns:html="http://www.w3.org/TR/REC-html40">
 <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
  <Author>ITConvergence</Author>
  <LastAuthor>ITConvergence</LastAuthor>
  <Created>2019-11-18T15:20:41Z</Created>
  <LastSaved>2019-11-18T16:59:45Z</LastSaved>
  <Version>16.00</Version>
 </DocumentProperties>
 <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
  <AllowPNG/>
 </OfficeDocumentSettings>
 <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
  <WindowHeight>7455</WindowHeight>
  <WindowWidth>20460</WindowWidth>
  <WindowTopX>32767</WindowTopX>
  <WindowTopY>32767</WindowTopY>
  <ProtectStructure>False</ProtectStructure>
  <ProtectWindows>False</ProtectWindows>
 </ExcelWorkbook>
 <Styles>
  <Style ss:ID="Default" ss:Name="Normal">
   <Alignment ss:Vertical="Bottom"/>
   <Borders/>
   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>
   <Interior/>
   <NumberFormat/>
   <Protection/>
  </Style>
  <Style ss:ID="s63">
   <NumberFormat ss:Format="General Date"/>
  </Style>
  <Style ss:ID="s64">
   <NumberFormat ss:Format="@"/>
  </Style>
  <Style ss:ID="s65">
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
  </Style>
  <Style ss:ID="s66">
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
   <NumberFormat ss:Format="Fixed"/>
  </Style>
  <Style ss:ID="s67">
   <NumberFormat ss:Format="Fixed"/>
  </Style>
  <Style ss:ID="s68">
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
   <NumberFormat ss:Format="0.000000000"/>
  </Style>
  <Style ss:ID="s69">
   <NumberFormat ss:Format="0.000000000"/>
  </Style>
  <Style ss:ID="s73">
   <Alignment ss:Horizontal="Center" ss:Vertical="Bottom"/>
   <Borders>
    <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>
    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>
   </Borders>
   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="12" ss:Color="#FFFFFF"
    ss:Bold="1"/>
   <Interior ss:Color="#305496" ss:Pattern="Solid"/>
  </Style>
 </Styles>
 <Worksheet ss:Name="Total Recurso x Org">
  <Table x:FullColumns="1"
   x:FullRows="1" ss:DefaultRowHeight="15">
   <Column ss:Width="99" ss:Span="1"/>
   <Column ss:Index="3" ss:Width="96.75"/>
   <Column ss:Width="85.5"/>
   <Column ss:Width="84"/>
   <Column ss:Width="102.75"/>
   <Column ss:Width="69.75"/>
   <Column ss:Width="115.5"/>
   <Column ss:Width="99"/>
   <Column ss:Width="102"/>
   <Column ss:Width="61.5"/>
   <Column ss:Width="83.25"/>
   <Column ss:Index="15" ss:Width="81"/>
   <Column ss:Width="197.25"/>
   <Column ss:Width="122.25"/>
   <Column ss:Width="61.5"/>
   <Column ss:Width="63"/>
   <Column ss:Width="83.25"/>
   <Column ss:Width="93.75"/>
   <Column ss:Width="105"/>
   <Column ss:Width="99.75"/>
   <Column ss:Width="108.75"/>
   <Column ss:Width="108"/>
   <Row ss:Height="15.75">
    <Cell ss:StyleID="s73"><Data ss:Type="String">Entidad Legal</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Periodo OPM</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Organizacion</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Periodo GL</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Calendario</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Metodo Costo</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Recurso</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Cant a distribuir (Usg UM)</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Sumatoria GL</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Costo Recurso</Data></Cell>
   </Row>
   <xsl:for-each select=".//G_REC_ORG">
   <Row>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//LEGAL_ENTITY_NAME"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//PERIOD_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//ORGANIZATION_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//PERIOD_GL_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//CALENDAR_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//COST_MTHD_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//RESOURCES"/></Data></Cell>
    <Cell ss:StyleID="s66"><Data ss:Type="Number"><xsl:value-of select=".//SUM_PROD_USAGE"/></Data></Cell>
    <Cell ss:StyleID="s66"><Data ss:Type="Number"><xsl:value-of select=".//SUM_GL_AMOUNT"/></Data></Cell>
    <Cell ss:StyleID="s68"><Data ss:Type="Number"><xsl:value-of select=".//RESOURCE_COST"/></Data></Cell>
   </Row>
   </xsl:for-each>
  </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Header x:Margin="0.3"/>
    <Footer x:Margin="0.3"/>
    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
   </PageSetup>
   <Selected/>
   <FreezePanes/>
   <FrozenNoSplit/>
   <SplitHorizontal>1</SplitHorizontal>
   <TopRowBottomPane>1</TopRowBottomPane>
   <ActivePane>2</ActivePane>
   <Panes>
    <Pane>
     <Number>3</Number>
    </Pane>
    <Pane>
     <Number>2</Number>
    </Pane>
   </Panes>
   <ProtectObjects>False</ProtectObjects>
   <ProtectScenarios>False</ProtectScenarios>
  </WorksheetOptions>
  <AutoFilter x:Range="R1C1:R22C10"
   xmlns="urn:schemas-microsoft-com:office:excel">
  </AutoFilter>
 </Worksheet>
 <Worksheet ss:Name="Recurso x art">
  <Table x:FullColumns="1"
   x:FullRows="1" ss:DefaultRowHeight="15">
   <Column ss:Width="75" ss:Span="1"/>
   <Column ss:Index="3" ss:Width="72.75"/>
   <Column ss:StyleID="s64" ss:Width="69"/>
   <Column ss:Width="425.25"/>
   <Column ss:Width="60"/>
   <Column ss:Width="78.75"/>
   <Column ss:Width="47.25"/>
   <Column ss:Width="63"/>
   <Column ss:Width="52.5"/>
   <Column ss:Width="57.75"/>
   <Column ss:Width="63"/>
   <Column ss:Width="61.5"/>
   <Column ss:Width="75"/>
   <Column ss:Width="61.5"/>
   <Column ss:Width="83.25"/>
   <Row ss:Height="15.75">
    <Cell ss:StyleID="s73"><Data ss:Type="String">Entidad Legal</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Periodo OPM</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Organizacion</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Articulo</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Descripcion </Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Calendario</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Metodo Costo</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Recurso</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Usg</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Usg UOM</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Item UOM</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Costo recurso/art</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Cant producida (art UM)</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Cant producida (Usg UM)</Data></Cell>
   </Row>
   <xsl:for-each select=".//G_PROD_REC">
   <Row>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//LEGAL_ENTITY_NAME"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//PERIOD_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//ORGANIZATION_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//ITEM_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//DESCRIPTION"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//CALENDAR_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//COST_MTHD_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//RESOURCES"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="Number"><xsl:value-of select=".//BURDEN_USAGE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//BURDEN_UOM"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//ITEM_UOM"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="Number"><xsl:value-of select=".//COST"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="Number"><xsl:value-of select=".//PRODUC"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="Number"><xsl:value-of select=".//CALC_PROD_USAGE"/></Data></Cell>
   </Row>
   </xsl:for-each>
  </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Header x:Margin="0.3"/>
    <Footer x:Margin="0.3"/>
    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
   </PageSetup>
   <Print>
    <ValidPrinterInfo/>
    <HorizontalResolution>360</HorizontalResolution>
    <VerticalResolution>360</VerticalResolution>
   </Print>
   <Selected/>
   <FreezePanes/>
   <FrozenNoSplit/>
   <SplitHorizontal>1</SplitHorizontal>
   <TopRowBottomPane>1</TopRowBottomPane>
   <ActivePane>2</ActivePane>
   <Panes>
    <Pane>
     <Number>3</Number>
    </Pane>
    <Pane>
     <Number>2</Number>
    </Pane>
   </Panes>
   <ProtectObjects>False</ProtectObjects>
   <ProtectScenarios>False</ProtectScenarios>
  </WorksheetOptions>
 </Worksheet>
 <Worksheet ss:Name="Suma GL x cuenta">
  <Table x:FullColumns="1"
   x:FullRows="1" ss:DefaultRowHeight="15">
   <Column ss:Width="75"/>
   <Column ss:Width="61.5"/>
   <Column ss:Width="72.75"/>
   <Column ss:Width="72.75"/>
   <Column ss:Width="47.25"/>
   <Column ss:StyleID="s67" ss:Width="87"/>
   <Column ss:Width="55.5"/>
   <Column ss:Width="36.75"/>
   <Column ss:Width="56.25"/>
   <Column ss:Width="41.25"/>
   <Column ss:Width="87.75"/>
   <Column ss:Width="53.25"/>
   <Column ss:Width="70.5"/>
   <Column ss:Width="72"/>
   <Column ss:Width="54.75"/>
   <Column ss:Width="19.5"/>
   <Column ss:StyleID="s67" ss:Width="105.75"/>
   <Column ss:StyleID="s67" ss:Width="110.25"/>
   <Column ss:StyleID="s67" ss:Width="150.75"/>
   <Column ss:Width="122.25" ss:Span="1"/>
   <Column ss:Index="22" ss:Width="61.5"/>
   <Column ss:Width="83.25"/>
   <Column ss:Width="108.75"/>
   <Column ss:Width="108"/>
   <Row ss:Height="15.75">
    <Cell ss:StyleID="s73"><Data ss:Type="String">Entidad Legal</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Periodo GL</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Organizacion</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Proceso</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Recurso</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Total Absorcion</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Ociosidad</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Ajuste</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Compania</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Cuenta</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Unidad Negocio</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Producto</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Unidad Prod</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Centro Costo</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Proyecto </Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">I/C</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Sum x Cuenta Debe</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Sum x Cuenta Haber</Data></Cell>
    <Cell ss:StyleID="s73"><Data ss:Type="String">Balance diario (debe-haber)</Data></Cell>
   </Row>
   <xsl:for-each select=".//G_GL_DETAIL">
   <Row>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//LEGAL_ENTITY_NAME"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//PERIOD_GL_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//ORGANIZATION_CODE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//FORMULA_CLASS_DESC"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//RESOURCES"/></Data></Cell>
    <Cell ss:StyleID="s66"><Data ss:Type="Number"><xsl:value-of select=".//SUM_GL_AMOUNT"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="Number"><xsl:value-of select=".//CONFIG_OCIOSIDAD"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="Number"><xsl:value-of select=".//CONFIG_AJUSTE"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//SEGMENT1"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//SEGMENT2"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//UNIDAD_NEGOCIO"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//PRODUCTO"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//UNIDAD_PROD"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//CENTRO_COSTO"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//PROYECTO"/></Data></Cell>
    <Cell ss:StyleID="s65"><Data ss:Type="String"><xsl:value-of select=".//INTERCOMPANY"/></Data></Cell>
    <Cell ss:StyleID="s66"><Data ss:Type="Number"><xsl:value-of select=".//SUM_ACCOUNTED_DR"/></Data></Cell>
    <Cell ss:StyleID="s66"><Data ss:Type="Number"><xsl:value-of select=".//SUM_ACCOUNTED_CR"/></Data></Cell>
    <Cell ss:StyleID="s66" ss:Formula="=+RC[-2]-RC[-1]"><Data ss:Type="Number">0</Data></Cell>
   </Row>
   </xsl:for-each>
  </Table>
  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
   <PageSetup>
    <Header x:Margin="0.3"/>
    <Footer x:Margin="0.3"/>
    <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>
   </PageSetup>
   <Selected/>
   <FreezePanes/>
   <FrozenNoSplit/>
   <SplitHorizontal>1</SplitHorizontal>
   <TopRowBottomPane>1</TopRowBottomPane>
   <ActivePane>2</ActivePane>
   <Panes>
    <Pane>
     <Number>3</Number>
    </Pane>
    <Pane>
     <Number>2</Number>
    </Pane>
   </Panes>
   <ProtectObjects>False</ProtectObjects>
   <ProtectScenarios>False</ProtectScenarios>
  </WorksheetOptions>
 </Worksheet>
</Workbook>
 </xsl:template>
</xsl:stylesheet>
