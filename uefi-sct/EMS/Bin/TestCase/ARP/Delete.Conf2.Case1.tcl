# 
#  Copyright 2006 - 2010 Unified EFI, Inc.<BR> 
#  Copyright (c) 2010, Intel Corporation. All rights reserved.<BR>
# 
#  This program and the accompanying materials
#  are licensed and made available under the terms and conditions of the BSD License
#  which accompanies this distribution.  The full text of the license may be found at 
#  http://opensource.org/licenses/bsd-license.php
# 
#  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
#  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
# 
################################################################################
CaseLevel         CONFORMANCE
CaseAttribute     AUTO
CaseVerboseLevel  DEFAULT

#
# test case Name, category, description, GUID...
#
CaseGuid        16C2A335-B0C6-4f67-807C-C51289FEF8B6
CaseName        Delete.Conf2.Case1
CaseCategory    ARP
CaseDescription {This case is to test the EFI_NOT_STARTED conforamce of        \
	               ARP.Delete}
################################################################################

#
# Begin log ...
#
BeginLog

Include ARP/include/Arp.inc.tcl

set hostmac    [GetHostMac]
set targetmac  [GetTargetMac]

VifUp 0 172.16.210.162 255.255.255.0
BeginScope _ARP_SPEC_CONFORMANCE_

UINTN                            R_Status
UINTN                            R_Handle
EFI_IP_ADDRESS                   R_StationAddress
EFI_ARP_CONFIG_DATA              R_ArpConfigData
EFI_IP_ADDRESS                   R_TargetSwAddress
UINTN                            R_ResolvedEvent
EFI_MAC_ADDRESS                  R_TargetHwAddress
UINTN                            R_EventContext
EFI_IP_ADDRESS                   R_IpAddressBuffer
EFI_MAC_ADDRESS                  R_MacAddressBuffer

ArpServiceBinding->CreateChild "&@R_Handle, &@R_Status"
GetAck
SetVar     [subst $ENTS_CUR_CHILD]  @R_Handle
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                                  \
                "ArpSBP.CreateChild - Create Child 1"                          \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

SetIpv4Address R_TargetSwAddress.v4 "172.16.210.161"
SetEthMacAddress R_TargetHwAddress "00:02:03:04:05:06"
SetVar R_IpAddressBuffer @R_TargetSwAddress
SetVar R_MacAddressBuffer @R_TargetHwAddress

#
# Check point
#
Arp->Delete {TRUE, &@R_IpAddressBuffer, &@R_Status}
GetAck
set assert [VerifyReturnStatus R_Status $EFI_NOT_STARTED]
RecordAssertion $assert $ArpConfigureConfAssertionGuid003                      \
                "Arp.Delete - returns EFI_NOT_STARTED when ARP driver instance \
                 has not been configured"                                      \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_NOT_STARTED"

#
# Check point
#
Arp->Delete {FALSE, &@R_MacAddressBuffer, &@R_Status}
GetAck
set assert [VerifyReturnStatus R_Status $EFI_NOT_STARTED]
RecordAssertion $assert $ArpConfigureConfAssertionGuid004                       \
                "Arp.Delete - returns EFI_NOT_STARTED when ARP driver instance \
                 has not been configured"                                      \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_NOT_STARTED"

Arp->Delete {TRUE, NULL, &@R_Status}
GetAck

Arp->Delete {FALSE, NULL, &@R_Status}
GetAck

ArpServiceBinding->DestroyChild {@R_Handle, &@R_Status}
GetAck

EndScope _ARP_SPEC_CONFORMANCE_
VifDown 0

#
# End Log
#
EndLog