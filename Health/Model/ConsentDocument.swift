//
//  ConsentDocument.swift
//  Health
//
//  Created by Vikhyath on 20/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import ResearchKit

var consentDocument: ORKConsentDocument = {
    
    let consentDocument = ORKConsentDocument()
    consentDocument.title = "CONSENT FORM"
    
    var consentSections: [ORKConsentSection] = []
    
    var consentSection = ORKConsentSection(type: .overview)
    consentSection.summary = "Consent Letter"
    consentSection.content = "This is mainly used for taking your consent for the collecting research data"
    consentSections.append(consentSection)
    
    consentSection = ORKConsentSection(type: .dataGathering)
    consentSection.summary = "Data Gathering"
    consentSection.content = "This app gathers the basic health data from you such as age height weight medical conditions"
    consentSections.append(consentSection)
    
    consentSection = ORKConsentSection(type: .privacy)
    consentSection.summary = "Your privacy"
    consentSection.content = "We take your privacy very seriously.We use advanced technologies to protect your data"
    consentSections.append(consentSection)
    
    consentSection = ORKConsentSection(type: .dataUse)
    consentSection.summary = "Data Use"
    consentSection.content = "We will ask you simple questions about your helth and body such as height weight and other body measurements and used only for research purposes"
    consentSections.append(consentSection)
    
    consentSection = ORKConsentSection(type: .timeCommitment)
    consentSection.summary = "Time Commitment"
    consentSection.content = "This survey should not take more than 10 minutes per week"
    consentSections.append(consentSection)
    
    consentDocument.sections = consentSections
    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: "Participant", dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))
    
    return consentDocument
}()
