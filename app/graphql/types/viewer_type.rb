module Types
  ViewerType = GraphQL::ObjectType.define do
    name "Viewer"
    description "The top level view of the graph"
    global_id_field :id
    interfaces [GraphQL::Relay::Node.interface]

    # entities
    field :chamber do
      type ChamberType
      argument :id, !types.ID, "The graph id of the chamber"
      resolve -> (obj, args, ctx) { Chamber.find(args["id"]) }
    end

    field :committee do
      type CommitteeType
      argument :id, !types.ID, "The graph id of the committee"
      resolve -> (obj, args, ctx) { Committee.find(args["id"]) }
    end

    field :hearing do
      type HearingType
      argument :id, !types.ID, "The graph id of the hearing"
      resolve -> (obj, args, ctx) { Hearing.find(args["id"]) }
    end

    field :bill do
      type BillType
      argument :id, !types.ID, "The graph id of the bill"
      resolve -> (obj, args, ctx) { Bill.find(args["id"]) }
    end

    # connections
    connection :chambers, -> { ChamberType.connection_type } do
      description "All chambers"
      resolve -> (obj, args, ctx) { Chamber.all }
    end

    connection :committees, -> { CommitteeType.connection_type } do
      description "All committees"
      resolve -> (obj, args, ctx) { Committee.all }
    end

    connection :hearings, -> { HearingType.connection_type } do
      description "All hearings"
      resolve -> (obj, args, ctx) { Hearing.all }
    end

    connection :bills, -> { BillType.connection_type } do
      description "All bills"

      argument :query, types.String, "Returns bills whose title or summary match the query"
      argument :from, DateTimeType, "Returns bills whose hearing is on or after the date-time"
      argument :to, DateTimeType, "Returns bills whose hearings is on or before the date-time"

      resolve -> (obj, args, ctx) do
        bills_query = Bill.by_date(start: args[:from], end: args[:to])
        bills_query = BillsSearchService.filter(bills_query, args[:query]) if args[:query].present?
        bills_query
      end
    end
  end
end
