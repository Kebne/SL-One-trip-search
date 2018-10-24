//
//  JourneySearchTests.swift
//  SL One trip searchTests
//
//  Created by Emil Lundgren on 2018-10-23.
//  Copyright © 2018 Kebne. All rights reserved.
//

import XCTest
@testable import SL_One_trip_search

class JourneySearchTests: XCTestCase {
    
    var sut: SearchService<SLJourneyPlanAPIResponse>!
    var mockURLSession: MockURLSession!

    override func setUp() {
        mockURLSession = MockURLSession()
        sut = SearchService<SLJourneyPlanAPIResponse>(urlSession: mockURLSession)
    }

    override func tearDown() {
        sut = nil
        mockURLSession = nil
    }
    
    func test_decodes_singleBusTrip() {
        mockURLSession.jsonString = JourneyStubGenerator.jsonStringWithSingleBusTrip
        guard let request = JourneySearchRequest(originId: "1", destinationId: "2", minutesFromNow: 0) else {
            XCTFail("Unable to create journey search request")
            return
        }
        
        sut.searchWith(request: request) {result in 
            switch result {
            case .success(let result): XCTAssertEqual(result.trips[0].legList[0].product.category, .bus)
            case .failure(_): XCTFail("Couldn't decode a trip from correct JSON.")
            }
        }
    }
    
    func test_calculatesCorrectDuration_busMetroTrip() {
        mockURLSession.jsonString = JourneyStubGenerator.jsonStringMetroBusTrip
        //originTime = "16:17:00"
        //destinationTime = "16:41:00"
        
        let expectedDurationSeconds = 24 * 60
        
        guard let request = JourneySearchRequest(originId: "1", destinationId: "2", minutesFromNow: 0) else {
            XCTFail("Unable to create journey search request")
            return
        }
        
        sut.searchWith(request: request) {result in
            switch result {
            case .success(let result):
                guard let combinedTrip = result.trips.first(where: {$0.legList.contains(where: {$0.product.category == .metro})}) else {
                    XCTFail("Couldn't find combined metro / bus trip")
                    return
                }
                XCTAssertEqual(expectedDurationSeconds, Int(combinedTrip.duration))
                
            case .failure(_): XCTFail("Couldn't decode a trip from correct JSON.")
            }
        }
    }

}


class JourneyStubGenerator {
    
    static var jsonStringWithSingleBusTrip : String {
        return """
{"Trip":[{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen","type":"ST","id":"A=1@O=Slussen@X=18074961@Y=59319591@U=74@L=400144006@","extId":"400144006","lon":18.074961,"lat":59.319591,"prognosisType":"PROGNOSED","time":"16:00:00","date":"2018-10-23","track":"G","rtTime":"16:00:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Finntorp","type":"ST","id":"A=1@O=Finntorp@X=18138883@Y=59306746@U=74@L=400140109@","extId":"400140109","lon":18.138883,"lat":59.306746,"prognosisType":"PROGNOSED","time":"16:10:00","date":"2018-10-23","rtTime":"16:10:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Finntorp (Nacka)@X=18138533@Y=59306782@U=74@L=300104046@","mainMastExtId":"300104046"},"JourneyDetailRef":{"ref":"1|16094|0|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  409","num":"14725","line":"409","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100409"},"idx":"0","name":"BUSS  409","number":"14725","category":"BUS","type":"JNY","reachable":true,"direction":"Duvnäs utskog"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":0,"tripId":"C-0","ctxRecon":"T$A=1@O=Slussen@L=400144006@a=128@$A=1@O=Finntorp@L=400140109@a=128@$201810231600$201810231610$        $","duration":"PT10M","checksum":"27335F54_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen","type":"ST","id":"A=1@O=Slussen@X=18075114@Y=59319574@U=74@L=400144007@","extId":"400144007","lon":18.075114,"lat":59.319574,"prognosisType":"PROGNOSED","time":"16:04:00","date":"2018-10-23","track":"H","rtTime":"16:04:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Finntorp","type":"ST","id":"A=1@O=Finntorp@X=18138883@Y=59306746@U=74@L=400140109@","extId":"400140109","lon":18.138883,"lat":59.306746,"prognosisType":"PROGNOSED","time":"16:14:00","date":"2018-10-23","rtTime":"16:14:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Finntorp (Nacka)@X=18138533@Y=59306782@U=74@L=300104046@","mainMastExtId":"300104046"},"JourneyDetailRef":{"ref":"1|16280|2|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  413","num":"14895","line":"413","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100413"},"idx":"0","name":"BUSS  413","number":"14895","category":"BUS","type":"JNY","reachable":true,"direction":"Björknäs centrum"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":1,"tripId":"C-1","ctxRecon":"T$A=1@O=Slussen@L=400144007@a=128@$A=1@O=Finntorp@L=400140109@a=128@$201810231604$201810231614$        $","duration":"PT10M","checksum":"2B336355_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen","type":"ST","id":"A=1@O=Slussen@X=18075114@Y=59319574@U=74@L=400144007@","extId":"400144007","lon":18.075114,"lat":59.319574,"prognosisType":"PROGNOSED","time":"16:08:00","date":"2018-10-23","track":"H","rtTime":"16:08:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Finntorp","type":"ST","id":"A=1@O=Finntorp@X=18138883@Y=59306746@U=74@L=400140109@","extId":"400140109","lon":18.138883,"lat":59.306746,"prognosisType":"PROGNOSED","time":"16:18:00","date":"2018-10-23","rtTime":"16:18:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Finntorp (Nacka)@X=18138533@Y=59306782@U=74@L=300104046@","mainMastExtId":"300104046"},"JourneyDetailRef":{"ref":"1|16281|0|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  413","num":"14896","line":"413","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100413"},"idx":"0","name":"BUSS  413","number":"14896","category":"BUS","type":"JNY","reachable":true,"direction":"Björknäs centrum"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":2,"tripId":"C-2","ctxRecon":"T$A=1@O=Slussen@L=400144007@a=128@$A=1@O=Finntorp@L=400140109@a=128@$201810231608$201810231618$        $","duration":"PT10M","checksum":"2F336755_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen","type":"ST","id":"A=1@O=Slussen@X=18075258@Y=59319565@U=74@L=400144008@","extId":"400144008","lon":18.075258,"lat":59.319565,"prognosisType":"PROGNOSED","time":"16:12:00","date":"2018-10-23","track":"I","rtTime":"16:12:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Finntorp","type":"ST","id":"A=1@O=Finntorp@X=18138883@Y=59306746@U=74@L=400140109@","extId":"400140109","lon":18.138883,"lat":59.306746,"prognosisType":"CALCULATED","time":"16:23:00","date":"2018-10-23","rtTime":"16:23:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Finntorp (Nacka)@X=18138533@Y=59306782@U=74@L=300104046@","mainMastExtId":"300104046"},"JourneyDetailRef":{"ref":"1|16783|1|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  422","num":"74225","line":"422","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100422"},"idx":"0","name":"BUSS  422","number":"74225","category":"BUS","type":"JNY","reachable":true,"direction":"Gustavsbergs centrum"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":3,"tripId":"C-3","ctxRecon":"T$A=1@O=Slussen@L=400144008@a=128@$A=1@O=Finntorp@L=400140109@a=128@$201810231612$201810231623$        $","duration":"PT11M","checksum":"33346C56_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen","type":"ST","id":"A=1@O=Slussen@X=18075114@Y=59319574@U=74@L=400144007@","extId":"400144007","lon":18.075114,"lat":59.319574,"prognosisType":"PROGNOSED","time":"16:16:00","date":"2018-10-23","track":"H","rtTime":"16:16:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Finntorp","type":"ST","id":"A=1@O=Finntorp@X=18138883@Y=59306746@U=74@L=400140109@","extId":"400140109","lon":18.138883,"lat":59.306746,"prognosisType":"PROGNOSED","time":"16:26:00","date":"2018-10-23","rtTime":"16:28:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Finntorp (Nacka)@X=18138533@Y=59306782@U=74@L=300104046@","mainMastExtId":"300104046"},"JourneyDetailRef":{"ref":"1|16295|1|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  413","num":"14897","line":"413","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100413"},"idx":"0","name":"BUSS  413","number":"14897","category":"BUS","type":"JNY","reachable":true,"direction":"Talludden"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":4,"tripId":"C-4","ctxRecon":"T$A=1@O=Slussen@L=400144007@a=128@$A=1@O=Finntorp@L=400140109@a=128@$201810231616$201810231626$        $","duration":"PT10M","checksum":"37346F55_4"}],"serverVersion":"1.2","dialectVersion":"1.23","requestId":"1540303144352","scrB":"1|OB|MTµ11µ5280µ5280µ5290µ5290µ0µ0µ5µ5280µ1µ-2147483646µ0µ1µ2|PDHµ89da1e91fb92158a5ef06580ae55532b","scrF":"1|OF|MTµ11µ5296µ5296µ5306µ5306µ0µ0µ5µ5293µ5µ-2147483646µ0µ1µ2|PDHµ89da1e91fb92158a5ef06580ae55532b"}
"""
    }
    
    static var jsonStringMetroBusTrip : String {
        return """
        {"Trip":[{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen (Södermalmstorg)","type":"ST","id":"A=1@O=Slussen (Södermalmstorg)@X=18070493@Y=59320266@U=74@L=400111003@","extId":"400111003","lon":18.070493,"lat":59.320266,"prognosisType":"PROGNOSED","time":"16:09:00","date":"2018-10-23","track":"N","rtTime":"16:12:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Barnängen","type":"ST","id":"A=1@O=Barnängen@X=18096742@Y=59309775@U=74@L=400110884@","extId":"400110884","lon":18.096742,"lat":59.309775,"prognosisType":"PROGNOSED","time":"16:26:00","date":"2018-10-23","rtTime":"16:29:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|433|0|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  2","num":"56991","line":"2","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100002"},"idx":"0","name":"BUSS  2","number":"56991","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":0,"tripId":"C-0","ctxRecon":"T$A=1@O=Slussen (Södermalmstorg)@L=400111003@a=128@$A=1@O=Barnängen@L=400110884@a=128@$201810231609$201810231626$        $","duration":"PT17M","checksum":"30337C40_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen (Södermalmstorg)","type":"ST","id":"A=1@O=Slussen (Södermalmstorg)@X=18070493@Y=59320266@U=74@L=400111003@","extId":"400111003","lon":18.070493,"lat":59.320266,"prognosisType":"PROGNOSED","time":"16:14:00","date":"2018-10-23","track":"N","rtTime":"16:15:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Medborgarplatsen (På Folkungagatan)","type":"ST","id":"A=1@O=Medborgarplatsen (På Folkungagatan)@X=18075060@Y=59314414@U=74@L=400110825@","extId":"400110825","lon":18.07506,"lat":59.314414,"prognosisType":"PROGNOSED","time":"16:18:00","date":"2018-10-23","rtTime":"16:15:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Medborgarplatsen (Stockholm)@X=18076390@Y=59314818@U=74@L=300101323@","mainMastExtId":"300101323"},"JourneyDetailRef":{"ref":"1|7409|1|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  53","num":"62210","line":"53","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100053"},"idx":"0","name":"BUSS  53","number":"62210","category":"BUS","type":"JNY","reachable":true,"direction":"Henriksdalsberget"},{"Origin":{"name":"Medborgarplatsen (På Folkungagatan)","type":"ST","id":"A=1@O=Medborgarplatsen (På Folkungagatan)@X=18075060@Y=59314414@U=74@L=400110825@","extId":"400110825","lon":18.07506,"lat":59.314414,"prognosisType":"PROGNOSED","time":"16:22:00","date":"2018-10-23","rtTime":"16:21:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Medborgarplatsen (Stockholm)@X=18076390@Y=59314818@U=74@L=300101323@","mainMastExtId":"300101323"},"Destination":{"name":"Tengdahlsgatan","type":"ST","id":"A=1@O=Tengdahlsgatan@X=18095510@Y=59310225@U=74@L=400110984@","extId":"400110984","lon":18.09551,"lat":59.310225,"prognosisType":"PROGNOSED","time":"16:34:00","date":"2018-10-23","rtTime":"16:32:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|8554|5|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  66","num":"66917","line":"66","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100066"},"idx":"1","name":"BUSS  66","number":"66917","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":1,"tripId":"C-1","ctxRecon":"T$A=1@O=Slussen (Södermalmstorg)@L=400111003@a=128@$A=1@O=Medborgarplatsen (På Folkungagatan)@L=400110825@a=128@$201810231614$201810231618$        $§T$A=1@O=Medborgarplatsen (På Folkungagatan)@L=400110825@a=128@$A=1@O=Tengdahlsgatan@L=400110984@a=128@$201810231622$201810231634$        $","duration":"PT20M","checksum":"42A7B727_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen (Södermalmstorg)","type":"ST","id":"A=1@O=Slussen (Södermalmstorg)@X=18070493@Y=59320266@U=74@L=400111003@","extId":"400111003","lon":18.070493,"lat":59.320266,"prognosisType":"PROGNOSED","time":"16:16:00","date":"2018-10-23","track":"N","rtTime":"16:16:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Barnängen","type":"ST","id":"A=1@O=Barnängen@X=18096742@Y=59309775@U=74@L=400110884@","extId":"400110884","lon":18.096742,"lat":59.309775,"prognosisType":"PROGNOSED","time":"16:33:00","date":"2018-10-23","rtTime":"16:33:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|434|0|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  2","num":"56992","line":"2","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100002"},"idx":"0","name":"BUSS  2","number":"56992","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":2,"tripId":"C-2","ctxRecon":"T$A=1@O=Slussen (Södermalmstorg)@L=400111003@a=128@$A=1@O=Barnängen@L=400110884@a=128@$201810231616$201810231633$        $","duration":"PT17M","checksum":"37338340_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen","type":"ST","id":"A=1@O=Slussen@X=18071743@Y=59319574@U=74@L=400101012@","extId":"400101012","lon":18.071743,"lat":59.319574,"prognosisType":"PROGNOSED","time":"16:17:00","date":"2018-10-23","track":"4","rtTime":"16:17:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Skanstull","type":"ST","id":"A=1@O=Skanstull@X=18075797@Y=59308508@U=74@L=400101522@","extId":"400101522","lon":18.075797,"lat":59.308508,"prognosisType":"PROGNOSED","time":"16:20:00","date":"2018-10-23","track":"2","rtTime":"16:19:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Skanstull (Stockholm)@X=18076166@Y=59307941@U=74@L=300109190@","mainMastExtId":"300109190"},"JourneyDetailRef":{"ref":"1|4347|0|74|23102018"},"JourneyStatus":"P","Product":{"name":"TUNNELBANA  18","num":"11118","line":"18","catOut":"METRO   ","catIn":"MET","catCode":"1","catOutS":"MET","catOutL":"TUNNELBANA ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100018"},"idx":"0","name":"TUNNELBANA  18","number":"11118","category":"MET","type":"JNY","reachable":true,"direction":"Farsta strand"},{"Origin":{"name":"Skanstull","type":"ST","id":"A=1@O=Skanstull@X=18075797@Y=59308508@U=74@L=400101522@","extId":"400101522","lon":18.075797,"lat":59.308508,"time":"16:21:00","date":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Skanstull (Stockholm)@X=18076166@Y=59307941@U=74@L=300109190@","mainMastExtId":"300109190"},"Destination":{"name":"Skanstull","type":"ST","id":"A=1@O=Skanstull@X=18077649@Y=59307843@U=74@L=400110400@","extId":"400110400","lon":18.077649,"lat":59.307843,"time":"16:25:00","date":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Skanstull (Stockholm)@X=18076166@Y=59307941@U=74@L=300109190@","mainMastExtId":"300109190"},"idx":"1","name":"","type":"WALK","duration":"PT4M","dist":129,"hide":true},{"Origin":{"name":"Skanstull","type":"ST","id":"A=1@O=Skanstull@X=18077649@Y=59307843@U=74@L=400110400@","extId":"400110400","lon":18.077649,"lat":59.307843,"prognosisType":"PROGNOSED","time":"16:28:00","date":"2018-10-23","rtTime":"16:32:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Skanstull (Stockholm)@X=18076166@Y=59307941@U=74@L=300109190@","mainMastExtId":"300109190"},"Destination":{"name":"Barnängen","type":"ST","id":"A=1@O=Barnängen@X=18097749@Y=59309937@U=74@L=400110881@","extId":"400110881","lon":18.097749,"lat":59.309937,"prognosisType":"PROGNOSED","time":"16:38:00","date":"2018-10-23","rtTime":"16:41:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|8023|1|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  57","num":"64785","line":"57","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100057"},"idx":"2","name":"BUSS  57","number":"64785","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":3,"tripId":"C-3","ctxRecon":"T$A=1@O=Slussen@L=400101012@a=128@$A=1@O=Skanstull@L=400101522@a=128@$201810231617$201810231620$        $§W$A=1@O=Skanstull@L=400101522@a=128@$A=1@O=Skanstull@L=400110400@a=128@$201810231621$201810231625$$§T$A=1@O=Skanstull@L=400110400@a=128@$A=1@O=Barnängen@L=400110881@a=128@$201810231628$201810231638$        $","duration":"PT21M","checksum":"FE773095_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen (Södermalmstorg)","type":"ST","id":"A=1@O=Slussen (Södermalmstorg)@X=18070493@Y=59320266@U=74@L=400111003@","extId":"400111003","lon":18.070493,"lat":59.320266,"prognosisType":"PROGNOSED","time":"16:22:00","date":"2018-10-23","track":"N","rtTime":"16:22:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Barnängen","type":"ST","id":"A=1@O=Barnängen@X=18096742@Y=59309775@U=74@L=400110884@","extId":"400110884","lon":18.096742,"lat":59.309775,"prognosisType":"PROGNOSED","time":"16:39:00","date":"2018-10-23","rtTime":"16:38:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|434|1|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  2","num":"56993","line":"2","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100002"},"idx":"0","name":"BUSS  2","number":"56993","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":4,"tripId":"C-4","ctxRecon":"T$A=1@O=Slussen (Södermalmstorg)@L=400111003@a=128@$A=1@O=Barnängen@L=400110884@a=128@$201810231622$201810231639$        $","duration":"PT17M","checksum":"3D338940_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen (Södermalmstorg)","type":"ST","id":"A=1@O=Slussen (Södermalmstorg)@X=18070493@Y=59320266@U=74@L=400111003@","extId":"400111003","lon":18.070493,"lat":59.320266,"prognosisType":"PROGNOSED","time":"16:28:00","date":"2018-10-23","track":"N","rtTime":"16:30:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Barnängen","type":"ST","id":"A=1@O=Barnängen@X=18096742@Y=59309775@U=74@L=400110884@","extId":"400110884","lon":18.096742,"lat":59.309775,"prognosisType":"PROGNOSED","time":"16:45:00","date":"2018-10-23","rtTime":"16:47:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|434|2|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  2","num":"56994","line":"2","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100002"},"idx":"0","name":"BUSS  2","number":"56994","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":5,"tripId":"C-5","ctxRecon":"T$A=1@O=Slussen (Södermalmstorg)@L=400111003@a=128@$A=1@O=Barnängen@L=400110884@a=128@$201810231628$201810231645$        $","duration":"PT17M","checksum":"43338F40_4"},{"ServiceDays":[{"planningPeriodBegin":"2018-10-22","planningPeriodEnd":"2018-12-06","sDaysR":"Mo - Fr","sDaysI":"nicht 6. Dez","sDaysB":"F9F3E7CF9F38"}],"LegList":{"Leg":[{"Origin":{"name":"Slussen (Södermalmstorg)","type":"ST","id":"A=1@O=Slussen (Södermalmstorg)@X=18070493@Y=59320266@U=74@L=400111003@","extId":"400111003","lon":18.070493,"lat":59.320266,"prognosisType":"PROGNOSED","time":"16:34:00","date":"2018-10-23","track":"N","rtTime":"16:35:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Slussen (Stockholm)@X=18071860@Y=59320284@U=74@L=300109192@","mainMastExtId":"300109192"},"Destination":{"name":"Barnängen","type":"ST","id":"A=1@O=Barnängen@X=18096742@Y=59309775@U=74@L=400110884@","extId":"400110884","lon":18.096742,"lat":59.309775,"prognosisType":"PROGNOSED","time":"16:51:00","date":"2018-10-23","rtTime":"16:51:00","rtDate":"2018-10-23","hasMainMast":true,"mainMastId":"A=1@O=Sofia (Stockholm)@X=18096230@Y=59309955@U=74@L=300101299@","mainMastExtId":"300101299"},"JourneyDetailRef":{"ref":"1|434|3|74|23102018"},"JourneyStatus":"P","Product":{"name":"BUSS  2","num":"56995","line":"2","catOut":"BUS     ","catIn":"BUS","catCode":"3","catOutS":"BUS","catOutL":"BUSS ","operatorCode":"SL","operator":"Storstockholms Lokaltrafik","admin":"100002"},"idx":"0","name":"BUSS  2","number":"56995","category":"BUS","type":"JNY","reachable":true,"direction":"Sofia"}]},"TariffResult":{"fareSetItem":[{"fareItem":[{"name":"NAME_PROD30","desc":"Helt pris","price":3100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Helt pris","price":4400,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Helt pris","price":6200,"cur":"SEK"},{"name":"NAME_PROD30","desc":"Reducerat pris","price":2100,"cur":"SEK"},{"name":"NAME_PROD31","desc":"Reducerat pris","price":3000,"cur":"SEK"},{"name":"NAME_PROD32","desc":"Reducerat pris","price":4100,"cur":"SEK"}],"name":"ONEWAY","desc":"SL"}]},"idx":6,"tripId":"C-6","ctxRecon":"T$A=1@O=Slussen (Södermalmstorg)@L=400111003@a=128@$A=1@O=Barnängen@L=400110884@a=128@$201810231634$201810231651$        $","duration":"PT17M","checksum":"49339540_4"}],"serverVersion":"1.2","dialectVersion":"1.23","requestId":"1540303733054","scrB":"1|OB|MTµ11µ5296µ5296µ5313µ5313µ0µ0µ5µ5290µ1µ-2147483646µ0µ1µ2|PDHµ89da1e91fb92158a5ef06580ae55532b","scrF":"1|OF|MTµ11µ5314µ5314µ5331µ5331µ0µ0µ5µ5309µ5µ-2147483646µ0µ1µ2|PDHµ89da1e91fb92158a5ef06580ae55532b"}
"""
    }
    

    
}
