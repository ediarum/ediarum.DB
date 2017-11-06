<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="index-id"/>
    <xsl:param name="index-type"/>
    <xsl:param name="index-label"/>
    <xsl:param name="index-status"/>
    <xsl:param name="connection-id"/>
    <xsl:param name="collection-id"/>
    <xsl:param name="data-collection"/>
    <xsl:param name="data-namespace"/>
    <xsl:param name="data-node"/>
    <xsl:param name="data-xmlid"/>
    <xsl:param name="data-span"/>

    <xsl:template match="/config">
        <config>
            <xsl:for-each select="*">
                <xsl:choose>
                    <xsl:when test="self::indexes">
                        <xsl:apply-templates select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <xsl:if test="not(indexes)">
                <indexes>
                    <xsl:call-template name="new-index"/>
                </indexes>
            </xsl:if>
        </config>
    </xsl:template>
    <xsl:template match="indexes">
        <indexes>
            <xsl:copy-of select="index[@id!=$index-id]"/>
            <xsl:call-template name="new-index"/>
        </indexes>
    </xsl:template>
    <xsl:template name="new-index">
        <index>
            <xsl:attribute name="id">
                <xsl:value-of select="$index-id"/>
            </xsl:attribute>
            <xsl:attribute name="type">
                <xsl:value-of select="$index-type"/>
            </xsl:attribute>
            <label>
                <xsl:value-of select="$index-label"/>
            </label>
            <xsl:if test="$index-type eq 'ediarum'">
                <parameter name="status">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$index-status"/>
                    </xsl:attribute>
                </parameter>
            </xsl:if>
            <xsl:if test="$index-type eq 'zotero'">
                <parameter name="connection-id">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$connection-id"/>
                    </xsl:attribute>
                </parameter>
                <parameter name="collection-id">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$collection-id"/>
                    </xsl:attribute>
                </parameter>
            </xsl:if>
            <xsl:if test="$index-type eq 'project'">
                <parameter name="data-collection">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$data-collection"/>
                    </xsl:attribute>
                </parameter>
                <parameter name="data-namespace">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$data-namespace"/>
                    </xsl:attribute>
                </parameter>
                <parameter name="data-node">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$data-node"/>
                    </xsl:attribute>
                </parameter>
                <parameter name="data-xmlid">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$data-xmlid"/>
                    </xsl:attribute>
                </parameter>
                <parameter name="data-span">
                    <xsl:attribute name="value">
                        <xsl:value-of select="$data-span"/>
                    </xsl:attribute>
                </parameter>
            </xsl:if>
        </index>
    </xsl:template>
</xsl:stylesheet>
