Deface::Override.new(
  virtual_path: 'spree/products/_order_details',
  name: 'add_part_description',
  insert_bottom: '[data-hook="order_item_description"]',
  text: "<% if item.product.assembly? %>
          <ul class='assembly_parts'>
            <% item.part_line_items.each do |v| %>
              <% pli_variant = v.variant %>
              <li>
                (<%= item.quantity * v.quantity %>)
                <%= link_to pli_variant.name, product_path(pli_variant.product) %>
                <% unless pli_variant.is_master? %>
                  (<%= pli_variant.options_text %>)
                <% end %>
                (<%= pli_variant.sku %>)
              </li>
            <% end %>
          </ul>
        <% end %>"
)