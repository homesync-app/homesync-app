import { AlertCircle, Inbox, Loader2 } from 'lucide-react';

interface PageStateProps {
  title: string;
  description?: string;
}

export const LoadingState = ({ title, description }: PageStateProps) => (
  <div className="state-card">
    <Loader2 className="w-8 h-8 text-primary animate-spin mx-auto mb-4" />
    <p className="text-base font-bold">{title}</p>
    {description && <p className="text-sm text-gray-400 mt-1">{description}</p>}
  </div>
);

export const EmptyState = ({ title, description }: PageStateProps) => (
  <div className="state-card">
    <Inbox className="w-8 h-8 text-gray-400 mx-auto mb-4" />
    <p className="text-base font-bold">{title}</p>
    {description && <p className="text-sm text-gray-400 mt-1">{description}</p>}
  </div>
);

export const ErrorState = ({ title, description }: PageStateProps) => (
  <div className="state-card border-rose-500/30">
    <AlertCircle className="w-8 h-8 text-rose-400 mx-auto mb-4" />
    <p className="text-base font-bold text-rose-300">{title}</p>
    {description && <p className="text-sm text-rose-200/80 mt-1">{description}</p>}
  </div>
);
