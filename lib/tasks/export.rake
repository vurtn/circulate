require "csv"

namespace :export do
  desc "Export verified members to CSV"
  task verified_members_to_csv: :environment do
    columns = %w[id preferred_name email]
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "verified_members-#{now}.csv"
    puts "writing member info to #{path}"

    CSV.open(path, "wb") do |csv|
      csv << [
        *columns
      ]
      Member.verified.in_batches(of: 100) do |members|
        members.each do |member|
          csv << [
            *member.attributes.values_at(*columns)
          ]
        end
      end
    end
  end

  desc "Export members and memberships to a flat CSV"
  task members_and_memberships_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "members-memberships-#{now}.csv"
    puts "writing member and membership info to #{path}"

    CSV.open(path, "wb") do |csv|
      csv << [
        *Member.column_names,
        *Membership.column_names.map { |n| "membership_#{n}" }
      ]
      Member.includes(:memberships).find_each do |member|
        if member.memberships.any?
          member.memberships.each do |membership|
            csv << [
              *member.attributes.values_at(*Member.column_names),
              *membership.attributes.values_at(*Membership.column_names)
            ]
          end
        else
          csv << [
            *member.attributes.values_at(*Member.column_names)
          ]
        end
      end
    end
  end

  desc "Export members and memberships to a flat CSV"
  task members_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "members-#{now}.csv"
    puts "writing member info to #{path}"

    CSV.open(path, "wb") do |csv|
      csv << [
        *Member.column_names,
        "level",
        *Membership.column_names.map { |n| "membership_#{n}" },
        "membership_amount"
      ]
      Member.find_each do |member|
        membership = member.memberships.order(created_at: "asc").first
        csv << [
          *member.attributes.values_at(*Member.column_names),
          "member",
          *membership.attributes.values_at(*Membership.column_names),
          membership.amount.format
        ]
      end
    end
  end

  desc "Export items to CSV"
  task items_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "all-items-#{now}.csv"
    puts "writing items to #{path}"
    columns = %w[
      id name description size brand model serial strength
      quantity checkout_notice status created_at updated_at
    ]
    CSV.open(path, "wb") do |csv|
      csv << [
        "complete_number",
        "code",
        "number",
        "categories",
        *columns
      ]
      Item.includes(:borrow_policy, :category_nodes).in_batches(of: 100) do |items|
        items.each do |item|
          csv << [
            item.complete_number,
            item.borrow_policy.code,
            item.number,
            item.category_nodes.map{|cn| cn.path_names.join("//")}.sort.join("; "),
            *item.attributes.values_at(*columns)
          ]
        end
      end
    end
  end

  desc "Export categories to CSV"
  task categories_to_csv: :environment do
    now = Time.current.rfc3339
    path = Rails.root + "exports" + "all-categories-#{now}.csv"
    puts "writing categories to #{path}"
    CSV.open(path, "wb") do |csv|
      csv << [
        "id",
        "name",
        "complete_name",
        "items_count"
      ]
      CategoryNode.in_batches(of: 100) do |nodes|
        nodes.each do |node|
          csv << [ 
            node.id,
            node.name,
            node.path_names.join("//"),
            node.categorizations_count
          ]
        end
      end
    end
  end

end
