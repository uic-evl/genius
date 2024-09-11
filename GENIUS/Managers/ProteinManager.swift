//
//  ProteinManager.swift
//  GENIUS
//
//  Created by Aaqel Shaik on 5/23/24.
//
//  Protein data from https://string-db.org/

import Foundation

// Class to model proteins as objects
class Protein: CustomStringConvertible {
    private var stringId: String        // STRING-db identifier
    private var ncbiTaxonId: String     // NCBI Taxonomic Identifier for species
    private var taxonName: String       // Taxonomic name for species
    private var preferredName: String   // Common name for protein
    private var annotation: String      // Description
    var description: String {
        return preferredName
    }
    
    init(stringId: String = "",
         ncbiTaxonId: String = "",
         taxonName: String = "",
         preferredName: String,
         annotation: String = "") {
        
        self.stringId = stringId
        self.ncbiTaxonId = ncbiTaxonId
        self.taxonName = taxonName
        self.preferredName = preferredName
        // Truncate annotation with trailing ellipsis
        self.annotation = String(annotation.prefix(350)) + " [...]"
    }
    
    func getStringId() -> String      {return self.stringId}
    func getNcbiTaxonId() -> String   {return self.ncbiTaxonId}
    func getTaxonName() -> String     {return self.taxonName}
    func getPreferredName() -> String {return self.preferredName}
    func getAnnotation() -> String    {return self.annotation}
    
}

// Class to model protein-protein interactions as objects
class Interaction: CustomStringConvertible {
    private var proteinA: String
    private var proteinB: String
    private var ncbiTaxonId: String
    private var score: Double       // Combined score
    private var nscore: Double      // Gene neighborhood score
    private var fscore: Double      // Gene fusion score
    private var pscore: Double      // Phylogenetic profile score
    private var ascore: Double      // Coexpression score
    private var escore: Double      // Experimental score
    private var dscore: Double      // Database score
    private var tscore: Double      // Textmining score
    
    var description: String {
        return "\(proteinA) -> \(proteinB)"
    }
    
    init(proteinA: String,
         proteinB: String,
         ncbiTaxonId: String,
         score: Double,
         nscore: Double,
         fscore: Double,
         pscore: Double,
         ascore: Double,
         escore: Double,
         dscore: Double,
         tscore: Double) {
        
        self.proteinA = proteinA
        self.proteinB = proteinB
        self.ncbiTaxonId = ncbiTaxonId
        self.score = score
        self.nscore = nscore
        self.fscore = fscore
        self.pscore = pscore
        self.ascore = ascore
        self.escore = escore
        self.dscore = dscore
        self.tscore = tscore
    }
    
    func getProteinA() -> String    {return self.proteinA}
    func getProteinB() -> String    {return self.proteinB}
    func getNcbiTaxonId() -> String {return self.ncbiTaxonId}
    func getScore() -> Double       {return self.score}
    func getNScore() -> Double      {return self.nscore}
    func getFScore() -> Double      {return self.fscore}
    func getPScore() -> Double      {return self.pscore}
    func getAScore() -> Double      {return self.ascore}
    func getEScore() -> Double      {return self.escore}
    func getDScore() -> Double      {return self.dscore}
    func getTScore() -> Double      {return self.tscore}
}

// Wrapper function
// 1) Get proteins data
// 2) Get interactions data
// 3) Update proteinsData with missing proteins from interactionsData
// 4) Return tuple
func getData(proteins: String, species: String, completion: @escaping ([Protein], [Interaction]) -> Void) {
    getProteins(proteinNames: proteins, speciesID: species) { proteinsArr in
        if !proteinsArr.isEmpty {
            let identifierString = proteinsArr.map {$0.getStringId()}.joined(separator: "%0d")
            getInteractions(identifiers: identifierString, species: species) { interactionsArr in
                if !interactionsArr.isEmpty {
                    updateMissingProteins(interactions: interactionsArr,
                                          proteins: proteinsArr,
                                          speciesID: species) { updatedProteins in
                        completion(updatedProteins, interactionsArr)
                    }
                } else {
                    print("No interactions were found.")
                    completion([],[])
                }
            }
        } else {
            print("Protein(s) couldn't be mapped to valid identifiers.")
            completion([],[])
        }
    }
}

// Function to get protein objects based on user-submitted names
func getProteins(proteinNames: String,
                    speciesID: String,
                    completion: @escaping ([Protein]) -> Void) {
    var proteinsArr: [Protein] = []
    let params: [String: Any] = [
        "identifiers": proteinNames
            .components(separatedBy: " ")
            .joined(separator: "\r"),
        "species": speciesID,
        "caller_identity": "Genius"
    ]
    
    requestAPI(method: "get_string_ids", params: params) { response in
        if let proteinString = response {
            let lines = proteinString
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")
            for line in lines {
                let components = line.components(separatedBy: "\t")
                let protein = Protein(stringId: components[1],
                                      ncbiTaxonId: components[2],
                                      taxonName: components[3],
                                      preferredName: components[4],
                                      annotation: components[5])
                proteinsArr.append(protein)
            }
            completion(proteinsArr)
        } else {
            print("The database returned NULL.")
            completion([])
        }
    }
}

// Function to get protein interactions
func getInteractions(identifiers: String,
                     species: String,
                     completion: @escaping ([Interaction]) -> Void) {
    var interactionsArr: [Interaction] = []
    let params: [String: Any] = [
        "identifiers": identifiers,
        "species": species,
        "caller_identity": "Genius"
    ]
            
    requestAPI(method: "network", params: params) { response in
        if let proteinString = response {

            let lines = proteinString
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .components(separatedBy: "\n")
            for line in lines {
                let components = line.components(separatedBy: "\t")
                let interaction = Interaction(proteinA: components[2],
                                              proteinB: components[3],
                                              ncbiTaxonId: components[4],
                                              score: Double(components[5]) ?? 0.0,
                                              nscore: Double(components[6]) ?? 0.0,
                                              fscore: Double(components[7]) ?? 0.0,
                                              pscore: Double(components[8]) ?? 0.0,
                                              ascore: Double(components[9]) ?? 0.0,
                                              escore: Double(components[10]) ?? 0.0,
                                              dscore: Double(components[11]) ?? 0.0,
                                              tscore: Double(components[12]) ?? 0.0)
                interactionsArr.append(interaction)
            }
            completion(interactionsArr)
        } else {
            print("The database returned NULL.")
            completion([])
        }
    }
}

// Function to update proteinsData with missing proteins
func updateMissingProteins(interactions: [Interaction],
                           proteins: [Protein],
                           speciesID: String,
                           completion: @escaping ([Protein]) -> Void) {
    let interactionSet = Set(interactions.map {$0.getProteinA()}).union(Set(interactions.map {$0.getProteinB()}))
    let proteinSet = Set(proteins.map {$0.getPreferredName()})
    let missingProteins = interactionSet.subtracting(proteinSet)
    if !missingProteins.isEmpty {
        getProteins(proteinNames: missingProteins.joined(separator: " "), speciesID: speciesID) { missingArr in
            if !missingArr.isEmpty {
                completion(proteins+missingArr)
            } else {
                print("Missing protein(s) were not found.")
                
                // Initialize empty protein objects if database returned nothing
                completion(proteins+missingProteins.map {Protein(preferredName: $0)})
            }
        }
    } else {completion(proteins)}
}

// General function to make API requests
// Returns a string with requested data
func requestAPI(method: String,
                params: [String:Any],
                completion: @escaping (String?) -> Void) {
    
    let stringAPIURL = "https://string-db.org/api"
    let outputFormat = "tsv-no-header"
    let requestURL = "\(stringAPIURL)/\(outputFormat)/\(method)"
    var stringResponse: String?
    let session = URLSession.shared

    if let url = URL(string: requestURL) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded",
                         forHTTPHeaderField: "Content-Type")

        let requestBody = params.map { (key, value) in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        request.httpBody = requestBody.data(using: .utf8)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                completion(nil)
                return
            }
            if let data = data {
                stringResponse = String(data: data, encoding: .utf8)
                completion(stringResponse)
            }
        }
        task.resume()
    } else {
        print("Invalid URL")
        completion(nil)
    }
}

