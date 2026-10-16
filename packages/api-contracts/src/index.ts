/**
 * PIXELDROP Shared API Contracts & Data Types
 */

export interface UpdateManifest {
  version: string;
  release_date: string;
  release_notes: string;
  mandatory: boolean;
  platforms: {
    'windows-x86_64': {
      signature: string;
      url: string;
      sha256: string;
      size: number;
    };
    'android-arm64': {
      url: string;
      sha256: string;
      size: number;
      package_name: string;
    };
    'android-universal': {
      url: string;
      sha256: string;
      size: number;
      package_name: string;
    };
  };
}

export type PairingStatus = 'pending' | 'approved' | 'rejected' | 'expired' | 'revoked';

export interface PairingSession {
  sessionId: string;
  qrToken: string;
  verificationCode: string; // 6-digit code e.g. "849201"
  createdAt: number;
  expiresAt: number;        // Exactly 5 minutes from creation
  status: PairingStatus;
  senderDevice: DeviceInfo;
  receiverDevice?: DeviceInfo;
}

export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  platform: 'android' | 'windows' | 'web';
  ipAddress?: string;
  port?: number;
}

export type TransferStatus = 'queued' | 'active' | 'paused' | 'completed' | 'failed' | 'cancelled';
export type TransferDirection = 'upload' | 'download';
export type TransferMode = 'local_lan' | 'cloud_r2';

export interface TransferItem {
  id: string;
  fileName: string;
  fileSize: number;
  fileType: string;
  sha256: string;
  direction: TransferDirection;
  mode: TransferMode;
  progress: number; // 0 to 100
  bytesTransferred: number;
  speedBytesPerSec: number;
  status: TransferStatus;
  errorMessage?: string;
  startedAt: number;
  completedAt?: number;
}

export interface ShareLink {
  shareId: string;
  fileName: string;
  fileSize: number;
  fileUrl: string;
  qrCodeUrl: string;
  expiresAt: number;
  downloadCount: number;
  downloadLimit?: number;
  hasPassword: boolean;
  isRevoked: boolean;
}
