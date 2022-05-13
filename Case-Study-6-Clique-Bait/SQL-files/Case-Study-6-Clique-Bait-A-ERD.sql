/*
	========	A. ENTITY RELATIONSHIP DIAGRAM		========
*/
--
--	Entity Relationship Diagram Result on dbdiagram.io
--	https://dbdiagram.io/d/624fcdd42514c97903f34e48
--
TABLE users {
    "user_id" INTEGER
    "cookie_id" VARCHAR(6)
    "start_date" TIMESTAMP
}

TABLE events {
    "visit_id" VARCHAR(6)
    "cookie_id" VARCHAR(6)
    "page_id" INTEGER
    "event_type" INTEGER
    "sequence_number" INTEGER
    "event_time" TIMESTAMP
}

TABLE event_identifier {
    "event_type" INTEGER
    "event_name" VARCHAR(13)
}

TABLE campaign_identifier {
    "campaign_id" INTEGER
    "products" VARCHAR(3)
    "campaign_name" VARCHAR(33)
    "start_date" TIMESTAMP
    "end_date" TIMESTAMP
}

TABLE page_hierarchy {
    "page_id" INTEGER
    "page_name" VARCHAR(14)
    "product_category" VARCHAR(9)
    "product_id" INTEGER
}

Ref: "event_identifier"."event_type" < "events"."event_type"

Ref: "page_hierarchy"."page_id" < "events"."page_id"

Ref: "users"."cookie_id" < "events"."cookie_id"
