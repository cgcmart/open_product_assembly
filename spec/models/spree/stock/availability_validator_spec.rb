module Spree
  module Stock
    describe AvailabilityValidator, type: :model do
      context "line item has no parts" do
        let!(:line_item) { create(:line_item, quantity: 5) }
        let!(:product) { line_item.product }

        subject { described_class.new }

        it 'is valid when supply is sufficient' do
          allow_any_instance_of(Stock::Quantifier).to receive(:can_supply?).and_return(true)
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end

        it 'is invalid when supply is insufficent' do
          allow_any_instance_of(Stock::Quantifier).to receive(:can_supply?).and_return(false)
          expect(line_item.errors).to receive(:[]).exactly(1).times.with(:quantity).and_return([])
          subject.validate(line_item)
        end

        it 'considers existing inventory_units sufficient' do
          allow_any_instance_of(Stock::Quantifier).to receive(:can_supply?).and_return(false)
          allow(line_item.inventory_units).to receive(:where).and_return([double] * 5)
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end
      end

      context "line item has parts" do
        let!(:order) { create(:order_with_line_items) }
        let(:line_item) { order.line_items.first }
        let(:product) { line_item.product }
        let(:variant) { line_item.variant }
        let(:parts) { (1..2).map { create(:variant) } }
        before { product.master.parts << parts }

        subject { described_class.new }

        it 'is valid when supply of all parts is sufficient' do
          allow_any_instance_of(Stock::Quantifier).to receive(:can_supply?).and_return(true)
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end

        it 'is invalid when supplies of all parts are insufficent' do
          allow_any_instance_of(Stock::Quantifier).to receive(:can_supply?).and_return(false)
          expect(line_item.errors).to receive(:[]).exactly(line_item.parts.size).times.with(:quantity).and_return([])
          subject.validate(line_item)
        end

        it 'is invalid when supply of 1 part is insufficient' do
          allow_any_instance_of(Stock::Quantifier).to receive(:can_supply?).and_return(false)
          inventory_units = [double(variant: line_item.parts.first)] * 5
          allow(line_item.parts.first).to receive(:inventory_units).and_return(inventory_units)
          expect(line_item.inventory_units).to receive(:where).and_return(inventory_units, [])
          expect(line_item.errors).to receive(:[]).exactly(1).times.with(:quantity).and_return([])
          subject.validate(line_item)
        end

        it 'is valid when supply of each part is sufficient' do
          line_item.parts.each do |part|
            allow(part).to receive(:inventory_units).and_return([double(variant: part)] * 5)
          end
          expect(line_item).not_to receive(:errors)
          subject.validate(line_item)
        end
      end
    end
  end
end