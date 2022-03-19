import Foundation

protocol WagesDeduction {
    
    var value:NSDecimalNumber { get }
    
    var detailString:String { get }
}

fileprivate let behavior = NSDecimalNumberHandler.init(roundingMode: NSDecimalNumber.RoundingMode.bankers, scale: 2, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)



//MARK: - 个人承担的五险部分
struct PersonalFiveInsurance {
    ///养老保险
    let payOld:NSDecimalNumber
    
    ///医疗保险
    let medical:NSDecimalNumber
    
    /// 失业保险
    let unemployment:NSDecimalNumber
}

extension PersonalFiveInsurance: WagesDeduction {
    var value: NSDecimalNumber  {
        return payOld.adding(medical, withBehavior: behavior)
            .adding(unemployment, withBehavior: behavior)
    }
    
    var detailString: String {
        return "三险总计: \(value) (养老: \(payOld.stringValue),医疗: \(medical.stringValue),失业: \(unemployment.stringValue))"
    }
}

//MARK:- 住房公积金

///住房公积金
struct HousingProvidentFund {
    let fund:NSDecimalNumber
}


extension HousingProvidentFund:WagesDeduction {
    
    var value: NSDecimalNumber {
        return fund
    }
    
    var detailString: String {
        return "住房公积金: \(value.stringValue)"
    }
}

//MARK: - 专项附加扣除
struct Preferentialdeduction  {
    let childrenEdu:NSDecimalNumber
    let parent:NSDecimalNumber
    let rentHouse:NSDecimalNumber
    let housingLoan:NSDecimalNumber
    
    
    static func creatOnlyRentHouse() -> Preferentialdeduction  {
        return Preferentialdeduction(childrenEdu: 0.0, parent: 0.0, rentHouse: 1500, housingLoan: 0.0)
    }
}

extension Preferentialdeduction:WagesDeduction {
    var value: NSDecimalNumber {
        return childrenEdu.adding(parent, withBehavior: behavior)
            .adding(rentHouse, withBehavior: behavior)
            .adding(housingLoan, withBehavior: behavior)
        
    }
    
    var detailString: String {
        return "专项附加扣除总计: \(value) (子女教育: \(childrenEdu.stringValue),赡养老人: \(parent.stringValue),租房: \(rentHouse.stringValue),购房贷款: \(housingLoan.stringValue))"
    }
}



//MARK: - 工资条
struct MonthWageInfo {
    ///月份
    let month:Int
    
    ///税前工资
    let total: NSDecimalNumber
    
    ///三险扣除
    let fiveAndHouseFund:WagesDeduction
    
    ///公积金
    let housingProvidentFund:WagesDeduction
    
    /// 专项附加扣除
    let preferentialdeduction:WagesDeduction
    
    ///个人所得税
    let personalIncomeTax:NSDecimalNumber
    
    ///累计纳税所得额
    let getTaxablePayment:NSDecimalNumber
    
    ///已预缴预扣税额
    let cumulativeTaxPayment:NSDecimalNumber
    
    ///实发金额
    let netAmount:NSDecimalNumber
    
}


extension MonthWageInfo: CustomStringConvertible {
    var description: String {
        var result = "\(month)月\n"
        result += "税前工资: \(total)\n"
        result += "\(fiveAndHouseFund.detailString)\n"
        result += "\(housingProvidentFund.detailString)\n"
        result += "\(preferentialdeduction.detailString)\n"
        result += "个人所得税: \(personalIncomeTax.stringValue)\n"
        result += "累计纳税所得额: \(getTaxablePayment.stringValue)\n"
        result += "已预缴预扣税额: \(cumulativeTaxPayment.stringValue)\n"
        result += "实发金额: \(netAmount.stringValue)\n\n"
        return result
    }
    
    
}

//MARK: - 工资计算器
///参考网址: https://www.gerensuodeshui.cn

struct WageCalculater {
    
    static let ladder:[(NSDecimalNumber,NSDecimalNumber,NSDecimalNumber)] = [
        (3_6000,  0.03,  0),
        (14_4000, 0.10,  2520),
        (30_0000, 0.20,  16920),
        (42_0000, 0.25,  31920),
        (66_0000, 0.30,  52920),
        (96_0000, 0.35,  8_5920),
        (NSDecimalNumber.init(value: Double.greatestFiniteMagnitude),0.45,18_1920),
        ]
    
    ///累计税前工资
    private(set) var grossSalary:NSDecimalNumber = 0.0

    /// 累计缴纳税额
    private(set) var cumulativeTaxPayment:NSDecimalNumber = 0.0

    
    /// 累计五险一金扣除
    private(set) var totalFiveAndHouseFund:NSDecimalNumber = 0.0

    /// 累计专项附加扣除
    private(set) var specialAdditionalDeduction:NSDecimalNumber = 0.0
    
    /// 累计其它扣除
    private(set) var other:NSDecimalNumber = 0.0
    
    
    ///计算累计应纳税所得额
     func getTaxablePayment() -> NSDecimalNumber {
        return grossSalary
            .subtracting(totalFiveAndHouseFund,withBehavior: behavior)
            .subtracting(specialAdditionalDeduction, withBehavior: behavior)
            .subtracting(other)
    }
    
    /// 计算所得税
    func getPersonalIncomeTax(taxablePayment:NSDecimalNumber) -> NSDecimalNumber {
        
        //工资在哪个档
        let idx = WageCalculater.ladder.firstIndex(where: { taxablePayment.decimalValue < $0.0.decimalValue })!
        
        var sub:NSDecimalNumber = 0
        if idx > 0 {
            for i in 0...idx {
                sub = sub.adding(WageCalculater.ladder[i].2, withBehavior: behavior)
            }
        }
        return  taxablePayment.multiplying(by: WageCalculater.ladder[idx].1, withBehavior: behavior)
            .subtracting(sub, withBehavior: behavior)
            .subtracting(cumulativeTaxPayment, withBehavior: behavior)
        
    }
    
    mutating func
        printCaculateMonth
        (
        month:Int,
        total:NSDecimalNumber,
        personalFiveInsurance:WagesDeduction,
        housingProvidentFund:WagesDeduction,
        preferentialdeduction:WagesDeduction)
    {
        let f = personalFiveInsurance
        let h = housingProvidentFund
        let p = preferentialdeduction
        
        debugPrint("\(month)月")
        grossSalary = grossSalary.adding(total, withBehavior: behavior)
        
        let fPlusH = f.value.adding(h.value, withBehavior: behavior)
        debugPrint("三险一金小计: \(fPlusH)")
        
        totalFiveAndHouseFund = totalFiveAndHouseFund
            .adding(fPlusH, withBehavior: behavior)
            
        specialAdditionalDeduction = specialAdditionalDeduction.adding(p.value, withBehavior: behavior)
        
        other = other.adding(5000.0, withBehavior: behavior)
        
        let getTaxablePayment = getTaxablePayment()
        
        let r = getPersonalIncomeTax(taxablePayment: getTaxablePayment)
        debugPrint("个人所得税: \(r.stringValue)")
        
        cumulativeTaxPayment =
            cumulativeTaxPayment.adding(r ,withBehavior: behavior)
        
        let result = total.subtracting(fPlusH,withBehavior: behavior)
            .subtracting(r)
        
        
        debugPrint("累计纳税所得额: \(getTaxablePayment.stringValue)")
        debugPrint("工资: \(result.stringValue)")
        debugPrint()
    }
    
    
    mutating func
        getMonthWageInfo
        (
        month:Int,
        total:NSDecimalNumber,
        personalFiveInsurance:WagesDeduction,
        housingProvidentFund:WagesDeduction,
        preferentialdeduction:WagesDeduction)
    -> MonthWageInfo
    {
        let f = personalFiveInsurance
        let h = housingProvidentFund
        let p = preferentialdeduction
        
   
        grossSalary = grossSalary.adding(total, withBehavior: behavior)
        
        let fPlusH = f.value.adding(h.value, withBehavior: behavior)
     
        
        totalFiveAndHouseFund = totalFiveAndHouseFund
            .adding(fPlusH, withBehavior: behavior)
            
        specialAdditionalDeduction = specialAdditionalDeduction.adding(p.value, withBehavior: behavior)
        
        other = other.adding(5000.0, withBehavior: behavior)
        
        let getTaxablePayment = getTaxablePayment()
        
        let r = getPersonalIncomeTax(taxablePayment: getTaxablePayment)
    
        
        cumulativeTaxPayment =
            cumulativeTaxPayment.adding(r ,withBehavior: behavior)
        
        let result = total.subtracting(fPlusH,withBehavior: behavior)
            .subtracting(r)
        
    
        return MonthWageInfo(month: month,
                             total: total,
                             fiveAndHouseFund: f,
                             housingProvidentFund: h,
                             preferentialdeduction: p,
                             personalIncomeTax: r,
                             getTaxablePayment: getTaxablePayment,
                             cumulativeTaxPayment: cumulativeTaxPayment, netAmount: result)
    }
}



func caculateToNowMonth3() {
    
    var calculater = WageCalculater()
    
    let fiveIns = PersonalFiveInsurance.init(payOld:1000, medical: 1000, unemployment: 500)
    
    let housing = HousingProvidentFund.init(fund: 500)
    
    let p = Preferentialdeduction.init(childrenEdu: 1000.0, parent: 2000.0, rentHouse: 200.0, housingLoan: 1000.0)
    
    calculater.printCaculateMonth(month: 1, total: 15000, personalFiveInsurance: fiveIns, housingProvidentFund: housing, preferentialdeduction: p)
    
    calculater.printCaculateMonth(month: 2, total: 45000, personalFiveInsurance: fiveIns, housingProvidentFund: housing, preferentialdeduction: p)
    
    calculater.printCaculateMonth(month: 3, total: 15000, personalFiveInsurance: fiveIns, housingProvidentFund: housing, preferentialdeduction: p)
    
}


///写代码
/// 1. 确定输入 --> 输出
/// 2. 参数校验
/// 3. 执行逻辑 --> 错误如何处理
/// 4. 返回结果
