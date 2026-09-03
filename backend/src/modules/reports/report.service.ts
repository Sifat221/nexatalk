import prisma from '../../prisma/client';

export class ReportService {
  async createReport(reporterId: string, data: { targetType: string; targetId: string; reason: string }) {
    const report = await prisma.report.create({
      data: {
        reporterId,
        targetType: data.targetType,
        targetId: data.targetId,
        reason: data.reason.trim(),
        status: 'PENDING',
      },
    });

    return report;
  }
}

export default new ReportService();
