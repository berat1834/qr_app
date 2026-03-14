import dotenv from 'dotenv';

dotenv.config();

export const config = {
  port: Number(process.env.PORT || 8080),
  playPackageName: process.env.PLAY_PACKAGE_NAME || '',
  playServiceAccountJson: process.env.PLAY_SERVICE_ACCOUNT_JSON || '',
  appleSharedSecret: process.env.APPLE_SHARED_SECRET || '',
};
