import Foundation

struct Response<D: Decodable>: Decodable {
    enum CodingKeys: CodingKey {
        case data

        enum Data: CodingKey {
            case attributes, id
        }
    }

    let id: String
    let attributes: D

    init(from decoder: Decoder) throws {
        let response = try decoder.container(keyedBy: CodingKeys.self)
        let data = try response.nestedContainer(keyedBy: CodingKeys.Data.self, forKey: .data)
        self.id = try data.decode(String.self, forKey: .id)
        self.attributes = try data.decode(D.self, forKey: .attributes)
    }
}
