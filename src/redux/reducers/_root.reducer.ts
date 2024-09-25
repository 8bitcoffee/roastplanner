import { combineReducers } from 'redux';
import errors from './errors.reducer.ts';
import user from './user.reducer.ts';

// Define the type for the errors reducer's state (you'll need to replace this with the actual type from errors.reducer)
// interface ErrorsState {
//   registrationMessage: string;
//   loginMessage: string;
// }

// Define the type for the user reducer's state (you'll need to replace this with the actual type from user.reducer)
// interface UserState {
//   id: number | null;
//   username: string | null;
// }

// Define the root state by combining the states of all reducers
export interface RootState {
  errors: typeof errors;
  user: typeof user;
}

// rootReducer is the primary reducer for our entire project.
// It bundles up all of the other reducers so our project can use them.
// This is imported in index.ts as rootSaga

// Combine the reducers into one root reducer
const rootReducer = combineReducers<RootState>({
  errors, // contains registrationMessage and loginMessage
  user, // will have an id and username if someone is logged in
});

export default rootReducer;