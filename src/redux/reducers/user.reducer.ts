import { Reducer } from 'redux';

// Define the shape of the user state
interface UserState {
  id?: number;
  username?: string;
}

// Define the possible action types and payloads
interface SetUserAction {
  type: 'SET_USER';
  payload: UserState;
}

interface UnsetUserAction {
  type: 'UNSET_USER';
}

// Union type for possible actions
type UserAction = SetUserAction | UnsetUserAction;

// Initial state, can be empty object or with optional user fields
const initialState: UserState = {};

// Type the reducer function
const userReducer: Reducer<UserState, UserAction> = (state = initialState, action): UserState => {
  switch (action.type) {
    case 'SET_USER':
      return action.payload;
    case 'UNSET_USER':
      return {};
    default:
      return state;
  }
};

// user will be on the redux state at:
// state.user
export default userReducer;
