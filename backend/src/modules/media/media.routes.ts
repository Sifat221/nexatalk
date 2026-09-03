import { Router } from 'express';
import multer from 'multer';
import mediaController from './media.controller';
import { authenticateJwt } from '../../middlewares/auth.middleware';

const router = Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 50 * 1024 * 1024, // 50MB max
  },
  fileFilter: (req, file, cb) => {
    // Validate MIME types
    const allowedMimes = [
      'image/jpeg',
      'image/png',
      'image/webp',
      'image/gif',
      'audio/m4a',
      'audio/mp4',
      'audio/aac',
      'audio/mpeg',
      'audio/wav',
      'audio/ogg',
      'application/pdf',
      'application/msword',
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'text/plain',
    ];

    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`Unsupported file format: ${file.mimetype}`));
    }
  },
});

router.use(authenticateJwt);

router.post('/upload', upload.single('file'), mediaController.upload);

export default router;
