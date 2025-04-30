import { ScorecardService } from "$lib/services/scorecard-service";
import type {
  GetPrediction,
  GetRaceCard,
  Prediction,
  Predictions,
  PredictionSummary,
  SubmitPrediction,
  ListPredictions,
  TeamSelection,
  BonusType,
  F1TeamId,
} from "../../../../declarations/backend/backend.did";
import { writable } from "svelte/store";
import { bonusToKey } from "$lib/utils/scorecard.helpers";

function createScorecardStore() {
  const { subscribe, set, update } = writable<TeamSelection[]>([]);
  const usedBonuses = writable<Record<string, boolean>>({});

  async function getPrediction(dto: GetPrediction): Promise<Prediction> {
    return new ScorecardService().getPrediction(dto);
  }

  async function getScorecard(dto: GetRaceCard): Promise<Prediction> {
    return new ScorecardService().getScorecard(dto);
  }

  async function listPredictions(dto: ListPredictions): Promise<Predictions> {
    return new ScorecardService().listPredictions(dto);
  }

  async function submitPrediction(dto: SubmitPrediction): Promise<any> {
    return new ScorecardService().submitPrediction(dto);
  }

  function isBonusAvailable(bonus: BonusType): boolean {
    let available = true;
    const key = bonusToKey(bonus);
    usedBonuses.subscribe((bonuses) => {
      available = !bonuses[key];
    })();
    return available;
  }

  async function toggleBonus(
    teamId: F1TeamId,
    driverType: "lead" | "second",
    bonus: BonusType,
  ) {
    update((selections) => {
      return selections.map((selection) => {
        if (selection.f1TeamId !== teamId) return selection;

        const bonusKey = bonusToKey(bonus);
        const bonusArray =
          driverType === "lead"
            ? selection.leadDriverBonuses
            : selection.secondDriverBonuses;

        const existingIndex = bonusArray.findIndex(
          (b) => bonusToKey(b) === bonusKey,
        );

        let newBonusArray;
        if (existingIndex >= 0) {
          newBonusArray = bonusArray.filter((_, i) => i !== existingIndex);
        } else {
          newBonusArray = [...bonusArray, bonus];
        }

        return {
          ...selection,
          [driverType === "lead" ? "leadDriverBonuses" : "secondDriverBonuses"]:
            newBonusArray,
        };
      });
    });

    usedBonuses.update((current) => {
      const key = bonusToKey(bonus);
      return { ...current, [key]: !current[key] };
    });
  }

  return {
    getPrediction,
    getScorecard,
    submitPrediction,
    listPredictions,
    subscribe,
    set,
    update,
    isBonusAvailable,
    toggleBonus,
    usedBonuses: { subscribe: usedBonuses.subscribe },
  };
}

export const scorecardStore = createScorecardStore();
