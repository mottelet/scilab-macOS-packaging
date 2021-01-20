<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:strip-space elements="*"/>
    <xsl:output method="xml" indent="yes"
          doctype-public="-//Apple//DTD PLIST 1.0//EN"
          doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="array[preceding::key[1][text()='JVMCapabilities']]">
        <array>
            <string>CommandLine</string>
            <string>BundledApp</string>
            <string>JNI</string>
        </array>
    </xsl:template>
</xsl:stylesheet>
