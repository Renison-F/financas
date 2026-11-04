import React, { createContext, useContext } from 'react';

export interface PrivacyState { hidden: boolean; toggle: () => void; }
const PrivacyContext = createContext<PrivacyState>({ hidden: false, toggle: () => {} });
export const PrivacyProvider = ({ value, children }: { value: PrivacyState; children: React.ReactNode }) => <PrivacyContext.Provider value={value}>{children}</PrivacyContext.Provider>;
export const usePrivacy = () => useContext(PrivacyContext);
