import type { BonusType } from "../../../../declarations/backend/backend.did";

export const bonusToKey = (bonus: BonusType): string => {
  if ("DidNotFinish" in bonus) return "DidNotFinish";
  if ("OnPole" in bonus) return "OnPole";
  if ("Lapped" in bonus) return "Lapped";
  if ("FirstOut" in bonus) return "FirstOut";
  if ("WinsRace" in bonus) return "WinsRace";
  return "FastestLap";
};

export function bonusToString(bonus: BonusType): string {
  if ("DidNotFinish" in bonus) return "DidNotFinish";
  if ("OnPole" in bonus) return "OnPole";
  if ("Lapped" in bonus) return "Lapped";
  if ("FirstOut" in bonus) return "FirstOut";
  if ("WinsRace" in bonus) return "WinsRace";
  return "FastestLap";
}

export function stringToBonus(type: string): BonusType {
  switch (type) {
    case "DidNotFinish":
      return { DidNotFinish: null };
    case "OnPole":
      return { OnPole: null };
    case "Lapped":
      return { Lapped: null };
    case "FirstOut":
      return { FirstOut: null };
    case "WinsRace":
      return { WinsRace: null };
    case "FastestLap":
      return { FastestLap: null };
    default:
      throw new Error("Invalid bonus type");
  }
}

export const ALL_BONUSES: BonusType[] = [
  { DidNotFinish: null },
  { OnPole: null },
  { Lapped: null },
  { FirstOut: null },
  { WinsRace: null },
  { FastestLap: null },
];
