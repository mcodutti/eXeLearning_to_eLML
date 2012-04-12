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
					<xsl:apply-templates select="./*[position()>1]" mode="entry"/>
				</entry>
			</xsl:when>
			<xsl:otherwise>
				<learningObject title="{.//p[@id='nodeTitle']}">
					<xsl:apply-templates select="./*[position()>1]" mode="lo"/>
				</learningObject>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
	============================================================
		Treat each IDevice
	============================================================
	-->
	<!-- 
		Activity
		Converted into a act/paragraph with 'act' icon
	-->
	<xsl:template match="div[@class='activityIdevice']" mode="lo">
		<act>
			<xsl:apply-templates select="." mode="entry"/>
		</act>
	</xsl:template>
	<xsl:template match="div[@class='activityIdevice']" mode="entry">
		<paragraph title="{.//span[@class='iDeviceTitle']}" icon="act"/>
		<xsl:apply-templates select=".//div[@class='iDevice_inner']"/>
	</xsl:template>
	<!--
		ClozeIdevice
		Converted into a act/selCheck/fillInBlanks
		Partially implemented (no solution, default gap)
	-->
	<xsl:template match="div[@class='ClozeIdevice']" mode="lo">
		<act>
			<xsl:apply-templates select="." mode="entry"/>
		</act>
	</xsl:template>
	<xsl:template match="div[@class='ClozeIdevice']" mode="entry">
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
	</xsl:template>
	
	<xsl:template match="input[contains(@id,'clozeBlank')]">
		<gap answers="x">x</gap>
	</xsl:template>
	<xsl:template match="span[contains(@id,'clozeAnswer')]"/>
	<!--
		FreeText
		Converted into a clarify without a title
	-->
	<xsl:template match="div[@class='FreeTextIDevice']" mode="lo">
		<clarify>
			<xsl:apply-templates select="." mode="entry"/>
		</clarify>
	</xsl:template>
	<xsl:template match="div[@class='FreeTextIDevice']" mode="entry">
		<xsl:apply-templates/>
	</xsl:template>
	<!--
		MultipleChoiceiDevice
		Converted into a act/selfCheck/multipleChoice
		Shuffle mode : yes
		Treated by eLML as a OneChoice if only one correct answer
	-->
	<xsl:template match="div[@class='MultiSelectIdevice']" mode="lo">
		<act>
			<xsl:apply-templates select="." mode="entry"/>
		</act>
	</xsl:template>
	<xsl:template match="div[@class='MultiSelectIdevice']" mode="entry">
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
	</xsl:template>
	<!--
		ObjectivesIDevice
		Converted into a clarify/paragraph with the objective icon
	-->
	<xsl:template match="div[@class='objectivesIdevice']" mode="lo">
		<clarify>
			<xsl:apply-templates select="." mode="entry"/>
		</clarify>
	</xsl:template>
	<xsl:template match="div[@class='objectivesIdevice']" mode="entry">
		<paragraph title="{.//span[@class='iDeviceTitle']}" icon="objective"/>
		<xsl:apply-templates select=".//div[@class='iDevice_inner']"/>
	</xsl:template>
	<!--
		ReflectionIDevice
		Converted into a act/paragraph with popup for the answer
		icon : question
	-->
	<xsl:template match="div[@class='ReflectionIdevice']" mode="lo">
		<act>
			<xsl:apply-templates select="." mode="entry"/>
		</act>
	</xsl:template>
	<xsl:template match="div[@class='ReflectionIdevice']" mode="entry">
			<paragraph title="{.//span[@class='iDeviceTitle']}" icon="question"/>
			<xsl:apply-templates select=".//div[@class='iDevice_inner']/div[1]"/>
			<xsl:apply-templates select=".//div[@class='feedback']"/>
	</xsl:template>
	<!--
		customIDevice
		Converted into a clarify/paragraph
		The icon is found in img/@src
	-->
	<xsl:template match="div[@class='customIdevice']" mode="lo">
		<clarify>
			<xsl:apply-templates select="." mode="entry"/>
		</clarify>
	</xsl:template>
	<xsl:template match="div[@class='customIdevice']" mode="entry">
			<paragraph
				title="{.//span[@class='iDeviceTitle']}"
				icon="{substring-before(.//img/@src,'.')}">
			</paragraph>
			<xsl:apply-templates select=".//div[@class='iDevice_inner']"/>
	</xsl:template>
	<!--
	============================================================
		Experimental IDevice conversions
	============================================================
	-->
	<!--
		TrueFalseIdevice
		!!! Under Development !!!
			Converted into a act>selfCheck>multipleChoice
			with oui/non answer (yes/no in french)
			Shuffle mode : no
	-->
	<xsl:template match="div[@class='TrueFalseIdevice']">
		<act>
		    <xsl:variable name="exTitle" select=".//span[@class='iDeviceTitle']"/>
				<xsl:for-each select="//div[@class='question']">
					<selfCheck title="{$exTitle}" shuffle="no">
    			    <multipleChoice>
	  			    <question>
					    <xsl:apply-templates select=".//div[starts-with(@id,'taquestion')]"/>
				    </question>
				    <xsl:for-each select=".//input">
					    <xsl:variable name="answerNumber" select="position()"/>
						<answer>
							<xsl:attribute name="correct">
								<xsl:if test="following-sibling::div[position()=$answerNumber and @even_steven='96']">yes</xsl:if>
								<xsl:if test="following-sibling::div[position()=$answerNumber and @even_steven='97']">no</xsl:if>
							</xsl:attribute>
							<!-- extract the feedback part -->	
							<!-- extract the text in the document -->
							<xsl:choose>
v								<xsl:when test="$answerNumber=1">Vrai</xsl:when>
								<xsl:otherwise>Faux</xsl:otherwise>
							</xsl:choose>
						</answer>
				    </xsl:for-each>
					</multipleChoice>
					</selfCheck>
				</xsl:for-each>
		</act>
	</xsl:template>	
	<!--
	============================================================
		iDevice's content
	============================================================
	-->

	<!-- paragraph -->
	<!-- extra <newLine/> to prevent successives paragraphs to be merged-->
	<xsl:template match="p">
		<paragraph>
			<xsl:apply-templates/>
			<xsl:if test="name(following-sibling::*[1])='p'">
				<newLine space="long"/>
			</xsl:if>
		</paragraph>
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
