<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:param name="synch-name"/>
    <xsl:param name="synch-type"/>
    <xsl:param name="source-server"/>
    <xsl:param name="source-resource"/>
    <xsl:param name="source-user"/>
    <xsl:param name="source-password"/>
    <xsl:param name="target-server"/>
    <xsl:param name="target-resource"/>
    <xsl:param name="target-user"/>
    <xsl:param name="target-password"/>
    <xsl:param name="target-group-name"/>
    <xsl:param name="target-mode"/>
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
            <xsl:call-template name="new-target"/>
        </synchronisation>
    </xsl:template>
    <xsl:template name="new-target">
        <xsl:choose>
            <xsl:when test="$synch-type='push'">
                <target>
                    <xsl:attribute name="type" select="$synch-type"/>
                    <label>
                        <xsl:value-of select="$synch-name"/>
                    </label>
                    <source-resource>
                        <xsl:value-of select="$source-resource"/>
                    </source-resource>
                    <target-server>
                        <xsl:value-of select="$target-server"/>
                    </target-server>
                    <target-resource>
                        <xsl:value-of select="$target-resource"/>
                    </target-resource>
                    <target-user>
                        <xsl:value-of select="$target-user"/>
                    </target-user>
                    <target-password>
                        <xsl:value-of select="$target-password"/>
                    </target-password>
                </target>
            </xsl:when>
            <xsl:when test="$synch-type='pull'">
                <target>
                    <xsl:attribute name="type" select="$synch-type"/>
                    <label>
                        <xsl:value-of select="$synch-name"/>
                    </label>
                    <source-server>
                        <xsl:value-of select="$source-server"/>
                    </source-server>
                    <source-resource>
                        <xsl:value-of select="$source-resource"/>
                    </source-resource>
                    <source-user>
                        <xsl:value-of select="$source-user"/>
                    </source-user>
                    <source-password>
                        <xsl:value-of select="$source-password"/>
                    </source-password>
                    <target-resource>
                        <xsl:value-of select="$target-resource"/>
                    </target-resource>
                    <target-group-name>
                        <xsl:value-of select="$target-group-name"/>
                    </target-group-name>
                    <target-mode>
                        <xsl:value-of select="$target-mode"/>
                    </target-mode>
                </target>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>