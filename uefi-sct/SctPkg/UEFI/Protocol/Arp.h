/** @file

  Copyright 2006 - 2016 Unified EFI, Inc.<BR>
  Copyright (c) 2010 - 2016, Intel Corporation. All rights reserved.<BR>   

  This program and the accompanying materials
  are licensed and made available under the terms and conditions of the BSD License
  which accompanies this distribution.  The full text of the license may be found at 
  http://opensource.org/licenses/bsd-license.php
 
  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
 
**/
/*++

Module Name:

  Arp.h

Abstract:

--*/

#ifndef _ARP_H_
#define _ARP_H_

#include <Protocol/ServiceBinding.h>

#define EFI_ARP_SERVICE_BINDING_PROTOCOL_GUID   \
  { 0xf44c00ee, 0x1f2c, 0x4a00, {0xaa, 0x09, 0x1c, 0x9f, 0x3e, 0x08, 0x00, 0xa3 }}

extern EFI_GUID gBlackBoxEfiArpServiceBindingProtocolGuid;

typedef EFI_SERVICE_BINDING_PROTOCOL EFI_ARP_SERVICE_BINDING_PROTOCOL;

#define EFI_ARP_PROTOCOL_GUID   \
  { 0xf4b427bb, 0xba21, 0x4f16, {0xbc, 0x4e, 0x43, 0xe4, 0x16, 0xab, 0x61, 0x9c }}

extern EFI_GUID gBlackBoxEfiArpProtocolGuid;

typedef struct _EFI_ARP_PROTOCOL EFI_ARP_PROTOCOL;

//*************************************************
// EFI_ARP_CONFIG_DATA
//*************************************************
typedef struct {
  UINT16                    SwAddressType;
  UINT8                     SwAddressLength;
  VOID                      *StationAddress;
  UINT32                    EntryTimeOut;
  UINT32                    RetryCount;
  UINT32                    RetryTimeOut;
}EFI_ARP_CONFIG_DATA;

//*************************************************
// EFI_ARP_FIND_DATA
//*************************************************
typedef struct {
  UINT32               Size;
  BOOLEAN              DenyFlag;
  BOOLEAN              StaticFlag;
  UINT16               HwAddressType;
  UINT16               SwAddressType;
  UINT8                HwAddressLength;
  UINT8                SwAddressLength;
} EFI_ARP_FIND_DATA;

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_CONFIGURE) (
  IN EFI_ARP_PROTOCOL          *This,
  IN EFI_ARP_CONFIG_DATA       *ConfigData OPTIONAL
  );

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_ADD) (
  IN EFI_ARP_PROTOCOL  *This,
  IN BOOLEAN           DenyFlag,
  IN VOID              *TargetSwAddress  OPTIONAL,
  IN VOID              *TargetHwAddress  OPTIONAL,
  IN UINT32            TimeoutValue,
  IN BOOLEAN           Overwrite
  );

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_FIND) (
  IN EFI_ARP_PROTOCOL     *This,
  IN BOOLEAN              BySwAddress,
  IN VOID                 *AddressBuffer    OPTIONAL,
  OUT UINT32              *EntryLength      OPTIONAL,
  OUT UINT32              *EntryCount       OPTIONAL,
  OUT EFI_ARP_FIND_DATA   **Entries,
  IN BOOLEAN              Refresh
  );

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_DELETE) (
  IN EFI_ARP_PROTOCOL      *This,
  IN BOOLEAN               BySwAddress,
  IN VOID                  *AddressBuffer OPTIONAL
  );

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_FLUSH) (
  IN EFI_ARP_PROTOCOL  *This
  );

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_REQUEST) (
  IN EFI_ARP_PROTOCOL  *This, 
  IN VOID              *TargetSwAddress  OPTIONAL,
  IN EFI_EVENT         ResolvedEvent     OPTIONAL,
  OUT VOID             *TargetHwAddress  
  );

typedef 
EFI_STATUS
(EFIAPI *EFI_ARP_CANCEL) (
  IN EFI_ARP_PROTOCOL  *This, 
  IN VOID              *TargetSwAddress  OPTIONAL,
  IN EFI_EVENT         ResolvedEvent     OPTIONAL
  );

struct _EFI_ARP_PROTOCOL {
  EFI_ARP_CONFIGURE         Configure;
  EFI_ARP_ADD               Add;
  EFI_ARP_FIND              Find;
  EFI_ARP_DELETE            Delete;
  EFI_ARP_FLUSH             Flush;
  EFI_ARP_REQUEST           Request;
  EFI_ARP_CANCEL            Cancel;
};

#endif
