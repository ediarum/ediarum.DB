<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="uuid"/>
    <xsl:param name="connection-name"/>
    <xsl:param name="group-id"/>
    <xsl:param name="api-key"/>
    <xsl:param name="style"/>
    <xsl:template match="/config">
        <config>
            <xsl:for-each select="*">
                <xsl:choose>
                    <xsl:when test="self::zotero">
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:if test="not(zotero)">
                <zotero>
                    <xsl:call-template name="new-connection"/>
                </zotero>
            </xsl:if>
        </config>
    </xsl:template>
    <xsl:template match="zotero">
        <zotero>
            <xsl:copy-of select="connection[@id!=$uuid]"/>
            <xsl:call-template name="new-connection"/>
        </zotero>
    </xsl:template>
    <xsl:template name="new-connection">
        <connection>
            <xsl:attribute name="id">
                <xsl:value-of select="$uuid"/>
            </xsl:attribute>
            <label>
                <xsl:value-of select="$connection-name"/>
            </label>
            <group-id>
                <xsl:value-of select="$group-id"/>
            </group-id>
            <api-key>
                <xsl:value-of select="$api-key"/>
            </api-key>
            <style>
                <xsl:value-of select="$style"/>
            </style>
        </connection>
    </xsl:template>
</xsl:stylesheet>
