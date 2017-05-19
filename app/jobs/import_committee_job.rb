class ImportCommitteeJob
  include Sidekiq::Worker

  def perform
    chambers = {
      "upper" => Chamber.find_by_name("House"),
      "lower" => Chamber.find_by_name("Senate")
    }

    HTTParty.get("https://openstates.org/api/v1/committees/?state=il").each do |committee|
      local_committee = Committee.find_or_initialize_by(external_id: committee["id"])

      local_committee.assign_attributes({
        external_id: committee["id"],
        name: committee["committee"],
        chamber: chambers[committee["chamber"]]
      })

      local_committee.save!
    end
  end
end
