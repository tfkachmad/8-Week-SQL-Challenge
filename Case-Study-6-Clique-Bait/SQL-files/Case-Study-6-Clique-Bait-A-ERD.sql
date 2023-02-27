--
-- Case study solusions for #8WeeksSQLChallenge by Danny Ma
-- Week 6 - Clique Bait
-- Part A - ERD Diagram
--
-- Create an entity relationship diagram at https://dbdiagram.io/home

Table "clique_bait"."event_identifier" {
  "event_type" INTEGER
  "event_name" VARCHAR(13)
}

Table "clique_bait"."campaign_identifier" {
  "campaign_id" INTEGER
  "products" VARCHAR(3)
  "campaign_name" VARCHAR(33)
  "start_date" timestamp
  "end_date" timestamp
}

Table "clique_bait"."page_hierarchy" {
  "page_id" INTEGER
  "page_name" VARCHAR(14)
  "product_category" VARCHAR(9)
  "product_id" INTEGER
}

Table "clique_bait"."users" {
  "user_id" INTEGER
  "cookie_id" VARCHAR(6)
  "start_date" timestamp
}

Table "clique_bait"."events" {
  "visit_id" VARCHAR(6)
  "cookie_id" VARCHAR(6)
  "page_id" INTEGER
  "event_type" INTEGER
  "sequence_number" INTEGER
  "event_time" timestamp
}


Ref: "clique_bait"."event_identifier"."event_type" < "clique_bait"."events"."event_type"

Ref: "clique_bait"."users"."cookie_id" < "clique_bait"."events"."cookie_id"

Ref: "clique_bait"."page_hierarchy"."page_id" < "clique_bait"."events"."page_id"
