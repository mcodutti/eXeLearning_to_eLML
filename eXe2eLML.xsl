<?xml version="1.0" encoding="UTF-8"?>
<!--
		This XSLT program converts a document from the eXeLearning format to the eLML format.
		More precisly it converts the "one HTML page" export of a eXeLearning document.
		
		Warning : It has been created for my own purpose and I don't know if it will work for you
		
		Distributed under the Creative-Common licence CC-BY
		Marco Codutti (Marco.Codutti@gmail.com)
-->
<xsl:stylesheet xmlns="http://www.elml.ch" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="UTF-8" indent="yes"/>
	<!--	
	============================================================
		Main structure : one lesson including one unit 
	============================================================ 
	-->
	<xsl:template match="/">
		<lesson xmlns="http://www.elml.ch" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.elml.ch ../../../_config/validate.xsd" label="{/html/head/title}" title="{/html/body/div/div[@id='main']/div[1]/div/p}">
			<unit label="{/html/head/title}" title="{//div[@id='main']/div[1]/div/p}">
				<xsl:apply-templates select="//div[@class='node']"/>
			</unit>
		</lesson>
	</xsl:template>
	<!--
	============================================================
		Treat a node : 
			The first node is used as the unit's <entry>
			The other ones become learningObjects
	============================================================
	-->
	<xsl:template match="div[@class='node']">
		<xsl:choose>
			<xsl:when test="position()=1">
				<entry>
					<xsl:apply-templates select="./*[position()>1]"/>
				</entry>
			</xsl:when>
			<xsl:otherwise>
				<learningObject title="{.//p[@id='nodeTitle']}">
					<xsl:apply-templates select="./*[position()>1]"/>
				</learningObject>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	============================================================
		objectivesIDevice
			Converted into a clarify/paragraph
			icon : objective
	============================================================
	-->
	<xsl:template match="div[@class='objectivesIdevice']">
		<clarify>
			<paragraph title="{.//span[@class='iDeviceTitle']}" icon="objective"/>
			<xsl:apply-templates select=".//div[@class='iDevice_inner']"/>
		</clarify>
	</xsl:template>
	<!--
	============================================================
		FreeTextIDevice
			Converted into a clarify/paragraph without a title
	============================================================
	-->
	<xsl:template match="div[@class='FreeTextIDevice']">
		<clarify>
			<xsl:apply-templates/>
		</clarify>
	</xsl:template>
	<!--
	============================================================
		customIDevice
			Converted into a clarify/paragraph
			The icon is found in img/@src
	============================================================
	-->
	<xsl:template match="div[@class='customIdevice']">
		<clarify>
			<paragraph
				title="{.//span[@class='iDeviceTitle']}"
				icon="{substring-before(.//img/@src,'.')}">
			</paragraph>
			<xsl:apply-templates select=".//div[@class='iDevice_inner']"/>
		</clarify>
	</xsl:template>
	<!--
	============================================================
		activityIdevice
			Converted into a act/paragraph with 'act' icon
	============================================================
	-->
	<xsl:template match="div[@class='activityIdevice']">
		<act>
			<paragraph title="{.//span[@class='iDeviceTitle']}" icon="act"/>
			<xsl:apply-templates select=".//div[@class='iDevice_inner']"/>
		</act>
	</xsl:template>
	<!--
	============================================================
		ReflectionIDevice (custom Idevice ?)
			Converted into a act/paragraph with popup for the answer
			icon : question
	============================================================
	-->
	<xsl:template match="div[@class='ReflectionIdevice']">
		<act>
			<paragraph title="{.//span[@class='iDeviceTitle']}" icon="question"/>
			<xsl:apply-templates select=".//div[@class='iDevice_inner']/div[1]"/>
			<xsl:apply-templates select=".//div[@class='feedback']"/>
		</act>
	</xsl:template>
	<!--
	============================================================
		MultipleChoiceiDevice
			Converted into a act>selfCheck>multipleChoice
			Shuffle mode : yes
			Treated by eLML as a OneChoice if only one correct answer
	============================================================
	-->
	<xsl:template match="div[@class='MultiSelectIdevice']">
		<act>
			<selfCheck title="{.//span[@class='iDeviceTitle']}" shuffle="yes">
			<multipleChoice>
				<question>
					<xsl:apply-templates select=".//div[@class='iDevice_inner']/div[@class='question']/div[1]"/>
				</question>
				<xsl:for-each select=".//tr[.//input]">
					<xsl:variable name="answerNumber" select="position()"/>
					<answer feedback="{position()}">
						<xsl:attribute name="correct">
							<xsl:if test=".//input/@value='True'">yes</xsl:if>
							<xsl:if test=".//input/@value='False'">no</xsl:if>
						</xsl:attribute>
						<xsl:attribute name="feedback">
							<xsl:value-of select="ancestor::div[@class='question']/div[last()]//p[$answerNumber]"/>
						</xsl:attribute>
						<xsl:apply-templates select="td[2]"/>
					</answer>
				</xsl:for-each>
			</multipleChoice>
			</selfCheck>
		</act>
	</xsl:template>
		<!--
	============================================================
		ClozeIdevice
			Not implemented yet
	============================================================
	-->
	<xsl:template match="div[@class='ClozeIdevice']">
		<act>
			<selfCheck title="{.//span[@class='iDeviceTitle']}" shuffle="yes">
			<fillInBlanks>
				<question>
					<xsl:apply-templates select=".//div[@class='iDevice_inner']/div[1]"/>
			  </question>
			  <gapText>
					<xsl:apply-templates select=".//div[@class='iDevice_inner']/div[2]"/>
			  </gapText>
			  <solution>[Mettre la solution ici]</solution>
			</fillInBlanks>
			</selfCheck>
		</act>
	</xsl:template>
	
	<xsl:template match="input[contains(@id,'clozeBlank')]">
		<gap answers="x">x</gap>
	</xsl:template>
	<xsl:template match="span[contains(@id,'clozeAnswer')]"/>
<!--
	============================================================
		iDevice's content
	============================================================
	-->

	<!-- paragraph -->
	<!-- extra <newLine/> to prevent successives paragraphs to be merged-->
	<xsl:template match="p">
		<parapraph>
			<xsl:apply-templates/>
			<newLine/>
		</parapraph>
	</xsl:template>
	<xsl:template match="br">
			<newLine/>
	</xsl:template>

	<!-- List -->
	<!-- Produce nothing if empty list -->
	<xsl:template match="ul|ol">
		<xsl:choose>
			<xsl:when test=".//li">
				<list>
					<xsl:choose>
						<xsl:when test="name()='ul'">
							<xsl:attribute name="listStyle">unordered</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="listStyle">ordered</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates/>
				</list>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="li">
		<item>
			<xsl:apply-templates/>
		</item>
	</xsl:template>
	
	<!-- Texts styles : bold, italic, courier -->
	<xsl:template match="b">
		<formatted style="bold">
			<xsl:apply-templates/>
		</formatted>
	</xsl:template>
	<xsl:template match="i">
		<formatted style="italic">
			<xsl:apply-templates/>
		</formatted>
	</xsl:template>
	<xsl:template match="font[@face='courier new,courier']">
		<formatted style="code">
			<xsl:apply-templates/>
		</formatted>
	</xsl:template>
	
	<!-- Images -->
	<xsl:template match="img">
		<popup title="Cliquez pour voir l'image">
			<multimedia src="../image/{@src}" type="jpeg"/>
		</popup>
	</xsl:template>

  <!-- feedback becomes popup -->
  <xsl:template match="div[@class='feedback']">
			<popup>
				<xsl:apply-templates/>
			</popup>
  </xsl:template>
<!--
	============================================================
		The followings are custom eXe extensions
	============================================================
	-->
	<!-- term -->
	<xsl:template match="span[@class='term']">
		<formatted style="input">
			<xsl:apply-templates/>
		</formatted>
	</xsl:template> 
 
</xsl:stylesheet>
