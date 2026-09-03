import fs from 'fs';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';
import { config } from '../../config/config';
import { logger } from '../../utils/logger.util';

export class StorageService {
  private uploadDir: string;

  constructor() {
    this.uploadDir = path.resolve(__dirname, '../../../uploads');
    if (!fs.existsSync(this.uploadDir)) {
      fs.mkdirSync(this.uploadDir, { recursive: true });
    }
  }

  async saveFile(file: Express.Multer.File, category: 'IMAGE' | 'DOCUMENT' | 'VOICE_NOTE' | 'AVATAR'): Promise<{
    url: string;
    filename: string;
    mimetype: string;
    size: number;
    category: string;
  }> {
    const ext = path.extname(file.originalname) || this.getExtensionFromMime(file.mimetype);
    const safeFilename = `${category.toLowerCase()}_${uuidv4()}${ext}`;

    if (config.storage.provider === 'local') {
      const filePath = path.join(this.uploadDir, safeFilename);
      await fs.promises.writeFile(filePath, file.buffer);

      const publicUrl = `${config.apiBaseUrl}/uploads/${safeFilename}`;
      return {
        url: publicUrl,
        filename: safeFilename,
        mimetype: file.mimetype,
        size: file.size,
        category,
      };
    }

    // If S3/MinIO is configured
    logger.info(`[Storage S3] Saving to S3 bucket ${config.storage.bucket}`);
    const publicUrl = `${config.storage.endpoint}/${config.storage.bucket}/${safeFilename}`;
    return {
      url: publicUrl,
      filename: safeFilename,
      mimetype: file.mimetype,
      size: file.size,
      category,
    };
  }

  private getExtensionFromMime(mime: string): string {
    switch (mime) {
      case 'image/jpeg': return '.jpg';
      case 'image/png': return '.png';
      case 'image/webp': return '.webp';
      case 'image/gif': return '.gif';
      case 'audio/m4a': return '.m4a';
      case 'audio/mp4': return '.mp4';
      case 'audio/aac': return '.aac';
      case 'audio/mpeg': return '.mp3';
      case 'audio/wav': return '.wav';
      case 'audio/ogg': return '.ogg';
      case 'application/pdf': return '.pdf';
      default: return '.bin';
    }
  }
}

export default new StorageService();
