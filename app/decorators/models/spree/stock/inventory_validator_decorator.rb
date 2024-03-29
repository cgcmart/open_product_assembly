Spree::Stock::InventoryValidator.class_eval do
  def validate(line_item)
    total_quantity = line_item.quantity_by_variant.values.sum

    if line_item.inventory_units.count != total_quantity
      line_item.errors[:inventory] << I18n.t(
        'spree.inventory_not_available',
        item: line_item.variant.name
      )
    end
  end
end