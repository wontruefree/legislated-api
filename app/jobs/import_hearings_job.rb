class ImportHearingsJob
  include Sidekiq::Worker

  def scraper
    @scraper ||= Scraper::HearingsTask.new
  end

  def perform
    chambers = {
      "upper" => Chamber.find_by_name("House")
      "lower" => Chamber.find_by_name("Senate")
    }

    HTTParty.get("http://openstates.org/api/v1/committees/?state=il").each |committee| do
      committee = Committee.find_or_initialize_by(committee["id"])
      committee.assign_attributes({
        external_id: committee["id"],
        name: committee["committee"],
        chamber: chambers[committee["chamber"]]
      })
      committee.save!
    end

    committee_hearings_attrs.each do |attrs|
      # rip out the hearing attrs for now
      hearing_attrs = attrs.delete(:hearing)

      # upsert hearing
      hearing = Hearing.find_or_initialize_by(hearing_attrs.slice(:external_id))
      hearing.assign_attributes(hearing_attrs.merge({
        committee: committee
      }))

      hearing.save!

      # enqueue the bills import
      ImportBillsJob.perform_async(hearing.id)
    end
  end
end
