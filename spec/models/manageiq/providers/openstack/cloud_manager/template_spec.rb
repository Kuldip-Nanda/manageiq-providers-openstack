describe ManageIQ::Providers::Openstack::CloudManager::Template do
  let(:ems) { FactoryGirl.create(:ems_openstack_with_authentication) }
  let(:image_attributes) { {:name => "image", :ram => "1"} }
  let(:template_openstack) { FactoryGirl.create :template_openstack, :ext_management_system => ems, :ems_ref => 'one_id' }
  let(:service) { double }

  context 'when create_image' do
    before do
      allow(ems).to receive(:with_provider_connection).with(:service => 'Image').and_yield(service)
    end

    context 'with correct data' do
      it 'should create image' do
        expect(service).to receive(:create_image).with(image_attributes).once
        subject.class.create_image(ems, image_attributes)
      end

      it 'should not raise error' do
        allow(service).to receive(:create_image).with(image_attributes).once
        expect do
          subject.class.create_image(ems, image_attributes)
        end.not_to raise_error
      end
    end

    context 'with incorrect data' do
      [Excon::Error::BadRequest, ArgumentError].map do |error|
        it "should raise error when #{error}" do
          allow(service).to receive(:create_image).with(image_attributes).and_raise(error)
          expect do
            subject.class.create_image(ems, image_attributes)
          end.to raise_error(MiqException::MiqOpenstackApiRequestError)
        end
      end
    end
  end
  context 'when raw_delete_image' do
    before do
      allow(ExtManagementSystem).to receive(:find).with(ems.id).and_return(ems)
      allow(ems).to receive(:with_provider_connection).with(:service => 'Compute').and_yield(service)
    end

    subject { template_openstack }

    it 'should delete image' do
      expect(service).to receive(:delete_image).with(template_openstack.ems_ref).once
      subject.delete_image
    end

    it 'should raise error' do
      allow(service).to receive(:delete_image).with(template_openstack.ems_ref).and_raise(Excon::Error::BadRequest)
      expect do
        subject.delete_image
      end.to raise_error(MiqException::MiqOpenstackApiRequestError)
    end
  end
end
