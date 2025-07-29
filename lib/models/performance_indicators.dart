import 'package:cloud_firestore/cloud_firestore.dart';

enum CompanyEvolution { HAUSSE, BAISSE, STABILITE }
enum CashFlowStatus { DIFFICILE, NORMALE, AISEE }
enum CompanyScale { PEU, MOYEN, BEAUCOUP }
enum ComplianceStatus { CONFORME, NON_CONFORME }

class CompanyIdentification {
  final String companyName;
  final String region;
  final DateTime creationDate;
  final String sector;
  final String legalForm;
  final String taxId;

  CompanyIdentification({
    required this.companyName,
    required this.region,
    required this.creationDate,
    required this.sector,
    required this.legalForm,
    required this.taxId,
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'region': region,
    'creationDate': Timestamp.fromDate(creationDate),
    'sector': sector,
    'legalForm': legalForm,
    'taxId': taxId,
  };

  factory CompanyIdentification.fromJson(Map<String, dynamic> json) {
    return CompanyIdentification(
      companyName: json['companyName'],
      region: json['region'],
      creationDate: (json['creationDate'] as Timestamp).toDate(),
      sector: json['sector'],
      legalForm: json['legalForm'],
      taxId: json['taxId'],
    );
  }
}

class EconomicPerformance {
  final double turnover;
  final CompanyEvolution turnoverEvolution;
  final double productionCosts;
  final CompanyEvolution costsEvolution;
  final CashFlowStatus cashFlowStatus;
  final Map<String, bool> fundingSources;

  EconomicPerformance({
    required this.turnover,
    required this.turnoverEvolution,
    required this.productionCosts,
    required this.costsEvolution,
    required this.cashFlowStatus,
    required this.fundingSources,
  });

  Map<String, dynamic> toJson() => {
    'turnover': turnover,
    'turnoverEvolution': turnoverEvolution.toString(),
    'productionCosts': productionCosts,
    'costsEvolution': costsEvolution.toString(),
    'cashFlowStatus': cashFlowStatus.toString(),
    'fundingSources': fundingSources,
  };

  factory EconomicPerformance.fromJson(Map<String, dynamic> json) {
    return EconomicPerformance(
      turnover: json['turnover'].toDouble(),
      turnoverEvolution: CompanyEvolution.values.firstWhere(
          (e) => e.toString() == json['turnoverEvolution']),
      productionCosts: json['productionCosts'].toDouble(),
      costsEvolution: CompanyEvolution.values.firstWhere(
          (e) => e.toString() == json['costsEvolution']),
      cashFlowStatus: CashFlowStatus.values.firstWhere(
          (e) => e.toString() == json['cashFlowStatus']),
      fundingSources: Map<String, bool>.from(json['fundingSources']),
    );
  }
}

class InvestmentEmployment {
  final int totalEmployees;
  final int newJobsCreated;
  final bool hasNewInvestments;
  final Map<String, bool> investmentTypes;

  InvestmentEmployment({
    required this.totalEmployees,
    required this.newJobsCreated,
    required this.hasNewInvestments,
    required this.investmentTypes,
  });

  Map<String, dynamic> toJson() => {
    'totalEmployees': totalEmployees,
    'newJobsCreated': newJobsCreated,
    'hasNewInvestments': hasNewInvestments,
    'investmentTypes': investmentTypes,
  };

  factory InvestmentEmployment.fromJson(Map<String, dynamic> json) {
    return InvestmentEmployment(
      totalEmployees: json['totalEmployees'],
      newJobsCreated: json['newJobsCreated'],
      hasNewInvestments: json['hasNewInvestments'],
      investmentTypes: Map<String, bool>.from(json['investmentTypes']),
    );
  }
}

class InnovationDigital {
  final CompanyScale innovationLevel;
  final CompanyScale digitalLevel;
  final CompanyScale aiLevel;

  InnovationDigital({
    required this.innovationLevel,
    required this.digitalLevel,
    required this.aiLevel,
  });

  Map<String, dynamic> toJson() => {
    'innovationLevel': innovationLevel.toString(),
    'digitalLevel': digitalLevel.toString(),
    'aiLevel': aiLevel.toString(),
  };

  factory InnovationDigital.fromJson(Map<String, dynamic> json) {
    return InnovationDigital(
      innovationLevel: CompanyScale.values.firstWhere(
          (e) => e.toString() == json['innovationLevel']),
      digitalLevel: CompanyScale.values.firstWhere(
          (e) => e.toString() == json['digitalLevel']),
      aiLevel: CompanyScale.values.firstWhere(
          (e) => e.toString() == json['aiLevel']),
    );
  }
}

class ConventionCompliance {
  final ComplianceStatus reportingCompliance;
  final int reportingDelayDays;
  final double investmentTargetPercent;
  final double employmentTargetPercent;
  final ComplianceStatus standardsCompliance;

  ConventionCompliance({
    required this.reportingCompliance,
    required this.reportingDelayDays,
    required this.investmentTargetPercent,
    required this.employmentTargetPercent,
    required this.standardsCompliance,
  });

  Map<String, dynamic> toJson() => {
    'reportingCompliance': reportingCompliance.toString(),
    'reportingDelayDays': reportingDelayDays,
    'investmentTargetPercent': investmentTargetPercent,
    'employmentTargetPercent': employmentTargetPercent,
    'standardsCompliance': standardsCompliance.toString(),
  };

  factory ConventionCompliance.fromJson(Map<String, dynamic> json) {
    return ConventionCompliance(
      reportingCompliance: ComplianceStatus.values.firstWhere(
          (e) => e.toString() == json['reportingCompliance']),
      reportingDelayDays: json['reportingDelayDays'],
      investmentTargetPercent: json['investmentTargetPercent'].toDouble(),
      employmentTargetPercent: json['employmentTargetPercent'].toDouble(),
      standardsCompliance: ComplianceStatus.values.firstWhere(
          (e) => e.toString() == json['standardsCompliance']),
    );
  }
}

class PerformanceIndicators {
  final String id;
  final String companyId;
  final DateTime reportingPeriod;
  final CompanyIdentification identification;
  final EconomicPerformance economicPerformance;
  final InvestmentEmployment investmentEmployment;
  final InnovationDigital innovationDigital;
  final ConventionCompliance conventionCompliance;

  PerformanceIndicators({
    required this.id,
    required this.companyId,
    required this.reportingPeriod,
    required this.identification,
    required this.economicPerformance,
    required this.investmentEmployment,
    required this.innovationDigital,
    required this.conventionCompliance,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'companyId': companyId,
    'reportingPeriod': Timestamp.fromDate(reportingPeriod),
    'identification': identification.toJson(),
    'economicPerformance': economicPerformance.toJson(),
    'investmentEmployment': investmentEmployment.toJson(),
    'innovationDigital': innovationDigital.toJson(),
    'conventionCompliance': conventionCompliance.toJson(),
  };

  factory PerformanceIndicators.fromJson(Map<String, dynamic> json) {
    return PerformanceIndicators(
      id: json['id'],
      companyId: json['companyId'],
      reportingPeriod: (json['reportingPeriod'] as Timestamp).toDate(),
      identification: CompanyIdentification.fromJson(json['identification']),
      economicPerformance: EconomicPerformance.fromJson(json['economicPerformance']),
      investmentEmployment: InvestmentEmployment.fromJson(json['investmentEmployment']),
      innovationDigital: InnovationDigital.fromJson(json['innovationDigital']),
      conventionCompliance: ConventionCompliance.fromJson(json['conventionCompliance']),
    );
  }
}
