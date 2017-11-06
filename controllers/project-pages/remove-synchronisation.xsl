<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="synch-name"/>
    <xsl:param name="synch-type"/>
    <xsl:template match="/config">
        <config>
            <xsl:for-each select="*">
                <xsl:choose>
                    <xsl:when test="self::synchronisation">
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </config>
    </xsl:template>
    <xsl:template match="synchronisation">
        <synchronisation>
            <xsl:copy-of select="target[label!=$synch-name or @type!=$synch-type]"/>
        </synchronisation>
    </xsl:template>
</xsl:stylesheet>