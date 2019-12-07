<xsl:stylesheet version="1.1" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" version="1.0" encoding="iso-8859-1" indent="yes"/>

<!-- For ETS 4 project files, replace the xmlns ending `13` with `11` -->
<xsl:template match="/" xmlns:b="http://knx.org/xml/project/13">

<xsl:for-each select="b:KNX/b:Project/b:Installations/b:Installation/b:Topology">
<datapoints>
<xsl:for-each select="b:Area/b:Line/b:DeviceInstance/b:ComObjectInstanceRefs/b:ComObjectInstanceRef">
<xsl:sort select="b:Connectors/b:Send/@GroupAddressRefId"/>
<xsl:if test="not(preceding::b:Connectors/b:Send/@GroupAddressRefId = current()/b:Connectors/b:Send/@GroupAddressRefId)">
<xsl:for-each select="b:Connectors">
<xsl:variable name="verz" select="document(concat(substring(../@RefId,0,7),'/',substring-before(../@RefId, '_O'), '.xml'))/b:KNX/b:ManufacturerData/b:Manufacturer/b:ApplicationPrograms/b:ApplicationProgram/b:Static/b:ComObjectTable/b:ComObject[@Id = ../../b:ComObjectRefs/b:ComObjectRef[@Id = current()/../@RefId]/@RefId]" />
<xsl:variable name="grosse">
  <xsl:choose>
    <xsl:when test="substring-after($verz/@ObjectSize,' ') = 'Bytes'">
	<xsl:value-of select="substring-before($verz/@ObjectSize,' ')*8" />
    </xsl:when>
    <xsl:otherwise>
	<xsl:value-of select="substring-before($verz/@ObjectSize,' ')" />
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>
<xsl:variable name="master" select="document('knx_master.xml')/b:KNX/b:MasterData/b:DatapointTypes/b:DatapointType[@SizeInBit = $grosse]" />
<xsl:variable name="master2" select="document('knx_master.xml')/b:KNX/b:MasterData/b:DatapointTypes/b:DatapointType/b:DatapointSubtypes/b:DatapointSubtype[@Id = current()/../@DatapointType]" />
<xsl:variable name="master3" select="document('knx_master.xml')/b:KNX/b:MasterData/b:DatapointTypes/b:DatapointType[@Id = current()/../@DatapointType]" />
<xsl:variable name="graddress" select="/b:KNX/b:Project/b:Installations/b:Installation/b:GroupAddresses/b:GroupRanges/b:GroupRange/b:GroupRange" />
<datapoint>
	<xsl:attribute name="stateBased">
		<xsl:value-of select="'true'"/>
	</xsl:attribute>
	<xsl:attribute name="name">
        <xsl:value-of select="$verz/@Name"/>
	</xsl:attribute>
	<xsl:attribute name="mainNumber">
		<xsl:choose>
		<xsl:when test="../@DatapointType != ''">
			<xsl:choose>
			<xsl:when test="string-length(../@DatapointType) > 5">
				<xsl:value-of select="$master2/../../@Number"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$master3/@Number"/>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$master/@Number"/>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="dptID">
		<xsl:choose>
		<xsl:when test="../@DatapointType != ''">
			<xsl:choose>
			<xsl:when test="string-length(../@DatapointType) > 5">
				<xsl:value-of select="concat($master2/../../@Number, '.',format-number($master2/@Number, '000') )"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($master3/@Number, '.001')"/>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($master/@Number,'.',format-number($master/b:DatapointSubtypes/b:DatapointSubtype/@Number, '000'))"/>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="priority">
	    <xsl:choose>
	    <xsl:when test="../@Priority">
		<xsl:value-of select="../@Priority"/>
	    </xsl:when>
	    <xsl:otherwise>
	    <xsl:value-of select="$verz/@Priority"/>
	    </xsl:otherwise>
	    </xsl:choose>
	</xsl:attribute>

	<xsl:for-each select="b:Send">
			<knxAddress type="group">
 				<xsl:value-of select="$graddress/b:GroupAddress[@Id = current()/@GroupAddressRefId]/@Address"/>
			</knxAddress>
  	</xsl:for-each>
	<expiration timeout="0"/>
		<xsl:choose>
		<xsl:when test="b:Receive">
			<updatingAddresses>
				<xsl:for-each select="b:Receive">
					<knxAddress type="group">
						<xsl:value-of select="$graddress/b:GroupAddress[@Id = current()/@GroupAddressRefId]/@Address"/>
					</knxAddress>
				</xsl:for-each>
			</updatingAddresses>
		</xsl:when>
		<xsl:otherwise>
			<updatingAddresses>
				<xsl:text></xsl:text>
			</updatingAddresses>
		</xsl:otherwise>
		</xsl:choose>
	<invalidatingAddresses>
		<xsl:text></xsl:text>
	</invalidatingAddresses>
</datapoint>
</xsl:for-each>
</xsl:if>
</xsl:for-each>
</datapoints>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
