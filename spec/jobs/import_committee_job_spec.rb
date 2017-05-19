describe ImportCommitteeJob do
  subject { described_class.new }

  describe '#perform' do
    let(:chamber) { Chamber.first }

    let(:committee) { create(:committee, :with_any_chamber) }
    let(:committee_attrs) { attributes_for(:committee, external_id: committee.external_id) }

    let(:http_response) {
      [{
        "id" => Faker::Lorem.word,
        "committee" => Faker::Lorem.word,
        "chamber" => %w{upper lower}.sample
      }]
    }

    before do
      allow(HTTParty).to receive(:get).and_return(http_response)
    end

    it "requests committees from external API" do
      subject.perform
      expect(HTTParty).to have_received(:get)
    end

    it 'updates committees that already exist' do
      subject.perform
      committee.reload
      expect(committee).to have_attributes(committee_attrs)
    end

    it "creates committees that don't exist" do
      expect { subject.perform(chamber.id) }.to change(Committee, :count).by(2)
    end

    context 'after catching a scraping error' do
      before do
        allow(mock_scraper).to receive(:run).and_raise(Scraper::Task::Error)
      end
    end

    context 'after catching an active record error' do
      before do
        allow_any_instance_of(Hearing).to receive(:save!).and_raise(ActiveRecord::ActiveRecordError)
      end

      it 'does not import bills' do
        expect(ImportBillsJob).to_not have_received(:perform_async)
      end
    end

  end
end
