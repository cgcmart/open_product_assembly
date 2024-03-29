Spree::Cart.AddItem.class_eval do
  def add_to_line_item_with_parts(variant: variant, quantity: quantity, options: {})
    add_to_line_item_without_parts(variant, quantity, options).tap do |line_item|
      populate_part_line_items(
        line_item,
        variant.parts_variants,
        options['selected_variants']
      )
    end
  end

  alias_method :add_to_line_item_without_parts, :add_to_line_item
  alias_method :add_to_line_item, :add_to_line_item_with_parts

  private

  def part_variants_match?(line_item, variant, quantity, options)
    if line_item.parts.any? && options["selected_variants"]
      selected_variant_ids = options["selected_variants"].values.map(&:to_i)
      matched = part_variant_ids(line_item) & selected_variant_ids

      matched == selected_variant_ids
    else
      true
    end
  end

  def part_variant_ids(line_item)
    line_item.part_line_items.map(&:variant_id)
  end

  def populate_part_line_items(line_item, parts, selected_variants)
    parts.each do |part|
      part_line_item = line_item.part_line_items.find_or_initialize_by(
        line_item: line_item,
        variant_id: variant_id_for(part, selected_variants)
      )

      part_line_item.update_attributes!(quantity: part.count)
    end
  end

  def variant_id_for(part, selected_variants)
    if part.variant_selection_deferred?
      selected_variants[part.part.id.to_s]
    else
      part.part.id
    end
  end
end