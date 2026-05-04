# Product Catalog Inline Detail Panel

## Problem/Feature Description

A retail company runs a Rails e-commerce application with a product listing page. The design team wants to add an "inline detail" experience: when a user clicks a product card from the list, the product details expand or replace a panel on the same page without navigating away, so the user can browse details and return to the full list without losing their scroll position. For users without JavaScript, clicking the card should navigate to the product detail page as normal.

The existing product listing page renders all products in a simple loop. The show action renders a full product detail page. Your job is to wire up the inline detail panel using Rails view helpers in a way that scopes the interactive region correctly without breaking the existing navigation behaviour or inadvertently hijacking unrelated links on the page.

## Output Specification

Produce the relevant Rails view files that implement this inline detail feature:

- `app/views/products/index.html.erb` — updated listing page with the interactive region
- `app/views/products/show.html.erb` — updated detail page that responds correctly to the inline request
- `app/views/products/_product.html.erb` — product card partial (if you use one)
- `IMPLEMENTATION_NOTES.md` — a short document describing: (a) which region is scoped for partial updates, (b) what the frame id is and why it was chosen, and (c) how the feature behaves when JavaScript is disabled

You may include additional partials as needed. The output does not need to be a runnable Rails app — focus on the view code.

## Input Files

The following files represent the current state of the application before your changes. Extract them before beginning.

=============== FILE: app/views/products/index.html.erb ===============
<h1>Products</h1>

<div id="products">
  <% @products.each do |product| %>
    <div class="product-card">
      <h2><%= product.name %></h2>
      <p><%= product.short_description %></p>
      <%= link_to "View details", product_path(product) %>
    </div>
  <% end %>
</div>

=============== FILE: app/views/products/show.html.erb ===============
<h1><%= @product.name %></h1>
<p><%= @product.description %></p>
<p>Price: <%= number_to_currency(@product.price) %></p>
<%= link_to "Back to products", products_path %>
