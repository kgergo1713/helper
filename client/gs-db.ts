export type JsonValue =
  | string
  | number
  | boolean
  | null
  | JsonValue[]
  | { [key: string]: JsonValue };

export interface GsDbItem<TData extends JsonValue = JsonValue> {
  id: string;
  project: string;
  collection: string;
  userId: string;
  data: TData;
  updatedAt: string;
}

export interface GsDbErrorResponse {
  error: {
    code: string;
    message: string;
  };
}

export class GsDbError extends Error {
  constructor(
    message: string,
    readonly status: number,
    readonly code: string,
  ) {
    super(message);
    this.name = "GsDbError";
  }
}