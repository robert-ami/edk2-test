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
CaseLevel         FUNCTION
CaseAttribute     AUTO
CaseVerboseLevel  DEFAULT

#
# test case Name, category, description, GUID...
#
CaseGuid          D49B5AD8-0F18-4a0a-AFC7-E5A24D6ACB8C
CaseName          NagleSWSA.Func3.Case2
CaseCategory      TCP
CaseDescription   {This item is to test the [EUT] correctly handles the bulk   \
                   data flow, the [EUT] should not respond with an             \
                   acknowledgement segment for each of the received segments.  \
                   A TCP SHOULD implement a delayed ACK, but an ACK should not \
                   be excessively delayed; in particular, the delay MUST be    \
                   less than 0.5 seconds. Need to be checked manually.}
################################################################################

Include TCP4/include/Tcp4.inc.tcl

proc CleanUpEutEnvironment {} {
  global RST
 
  UpdateTcpSendBuffer TCB -c $RST
  SendTcpPacket TCB
 
  DestroyTcb
  DestroyPacket
  DelEntryInArpCache

  Tcp4ServiceBinding->DestroyChild "@R_Tcp4Handle, &@R_Status"
  GetAck
 
  Tcp4ServiceBinding->DestroyChild "@R_Accept_NewChildHandle, &@R_Status"
  GetAck

  BS->CloseEvent "@R_Accept_CompletionToken.Event, &@R_Status"
  GetAck

  EndLogPacket
  EndScope _TCP4_RFC_COMPATIBILITY_
  EndLog
}

#
# Begin log ...
#
BeginLog

#
# BeginScope on OS.
#
BeginScope _TCP4_RFC_COMPATIBILITY_

BeginLogPacket NagleSWSA.Func4.Case2   "host $DEF_EUT_IP_ADDR and host         \
                                             $DEF_ENTS_IP_ADDR"
CreatePayload BoundaryPayload Incr 1 0x01

#
# Parameter Definition
# R_ represents "Remote EFI Side Parameter"
# L_ represents "Local OS Side Parameter"
#
UINTN                            R_Status
UINTN                            R_Tcp4Handle
UINTN                            R_Context

EFI_TCP4_ACCESS_POINT            R_Configure_AccessPoint
EFI_TCP4_OPTION                  R_Configure_ControlOption
EFI_TCP4_CONFIG_DATA             R_Configure_Tcp4ConfigData

EFI_TCP4_COMPLETION_TOKEN        R_Accept_CompletionToken
EFI_TCP4_LISTEN_TOKEN            R_Accept_ListenToken
UINTN                            R_Accept_NewChildHandle

#
# Initialization of TCB related on OS side.
#
CreateTcb TCB $DEF_ENTS_IP_ADDR $DEF_ENTS_PRT $DEF_EUT_IP_ADDR $DEF_EUT_PRT

LocalEther  $DEF_ENTS_MAC_ADDR
RemoteEther $DEF_EUT_MAC_ADDR
LocalIp     $DEF_ENTS_IP_ADDR
RemoteIp    $DEF_EUT_IP_ADDR

#
# Add an entry in ARP cache.
#
AddEntryInArpCache

#
# Create Tcp4 Child.
#
Tcp4ServiceBinding->CreateChild "&@R_Tcp4Handle, &@R_Status"
GetAck
SetVar     [subst $ENTS_CUR_CHILD]  @R_Tcp4Handle
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                                  \
                "Tcp4SBP.CreateChild - Create Child 1."                        \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

#
# Configure TCP instance.
#
SetVar R_Configure_AccessPoint.UseDefaultAddress      FALSE
SetIpv4Address R_Configure_AccessPoint.StationAddress $DEF_EUT_IP_ADDR
SetIpv4Address R_Configure_AccessPoint.SubnetMask     $DEF_EUT_MASK
SetVar R_Configure_AccessPoint.StationPort            $DEF_EUT_PRT
SetIpv4Address R_Configure_AccessPoint.RemoteAddress  0
SetVar R_Configure_AccessPoint.RemotePort             0
SetVar R_Configure_AccessPoint.ActiveFlag             FALSE

SetVar R_Configure_ControlOption.ReceiveBufferSize      64000
SetVar R_Configure_ControlOption.SendBufferSize         4096
SetVar R_Configure_ControlOption.MaxSynBackLog          0
SetVar R_Configure_ControlOption.ConnectionTimeout      20
SetVar R_Configure_ControlOption.DataRetries            0
SetVar R_Configure_ControlOption.FinTimeout             0
SetVar R_Configure_ControlOption.KeepAliveProbes        0
SetVar R_Configure_ControlOption.KeepAliveTime          0
SetVar R_Configure_ControlOption.KeepAliveInterval      0
SetVar R_Configure_ControlOption.EnableNagle            FALSE
SetVar R_Configure_ControlOption.EnableTimeStamp        FALSE
SetVar R_Configure_ControlOption.EnableWindowScaling    FALSE
SetVar R_Configure_ControlOption.EnableSelectiveAck     FALSE
SetVar R_Configure_ControlOption.EnablePathMtuDiscovery FALSE

SetVar R_Configure_Tcp4ConfigData.TypeOfService      0
SetVar R_Configure_Tcp4ConfigData.TimeToLive         128
SetVar R_Configure_Tcp4ConfigData.AccessPoint        @R_Configure_AccessPoint
SetVar R_Configure_Tcp4ConfigData.ControlOption      &@R_Configure_ControlOption

Tcp4->Configure {&@R_Configure_Tcp4ConfigData, &@R_Status}
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                                  \
                "Tcp4.Configure - Configure Child 1."                          \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

#
# Call Tcp4.Accept for an passive TCP instance.
#
BS->CreateEvent "$EVT_NOTIFY_SIGNAL, $EFI_TPL_CALLBACK, 1, &@R_Context,        \
                 &@R_Accept_CompletionToken.Event, &@R_Status"
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $GenericAssertionGuid                                  \
                "BS.CreateEvent."                                              \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

SetVar R_Accept_NewChildHandle 0
SetVar R_Accept_ListenToken.CompletionToken @R_Accept_CompletionToken
SetVar R_Accept_ListenToken.CompletionToken.Status $EFI_INCOMPATIBLE_VERSION

Tcp4->Accept {&@R_Accept_ListenToken, &@R_Status}
GetAck
set assert [VerifyReturnStatus R_Status $EFI_SUCCESS]
RecordAssertion $assert $Tcp4NagleSWSAFunc3AssertionGuid002                    \
                "Tcp4.Accept - Open an passive connection."                    \
                "ReturnStatus - $R_Status, ExpectedStatus - $EFI_SUCCESS"

#
# Handles the three-way handshake.
# Make [EUT] enter ESTABLISHED state through passive connection open.
#
UpdateTcpSendBuffer TCB -c $SYN
SendTcpPacket TCB

ReceiveTcpPacket TCB 5

UpdateTcpSendBuffer TCB -c $ACK
SendTcpPacket TCB

#
# Get the NewChildHandle value.
#
GetVar R_Accept_ListenToken.NewChildHandle
SetVar R_Accept_NewChildHandle ${R_Accept_ListenToken.NewChildHandle}

#
# Configure the [OS] to send 20 full-sized data segments. There should be at
# least an ACK for every second segment.
#
for { set i 0} { $i < 20 } { incr i } {
  UpdateTcpSendBuffer TCB -c $ACK -p BoundaryPayload
  SendTcpPacket TCB
}

#
# EUT should delayed ACK the data segment, but the delay MUST be less than 0.5
# second.
#
UpdateTcpSendBuffer TCB -c $ACK -p BoundaryPayload
SendTcpPacket TCB

Stall 5
#
# Clean up the environment on EUT side.
#
CleanUpEutEnvironment
