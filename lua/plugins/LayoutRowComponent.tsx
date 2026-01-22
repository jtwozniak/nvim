"use client";

import { ContentItem, LayoutRow } from "@mb/components";

import type { LayoutRowFragment } from "@/graphql/generated";
import { CMSWrapper } from "@/hoc/CMSWrapper";
import { layoutRowSchema } from "@/schemas";

export function LayoutRowComponent(data: LayoutRowFragment) {
  return (
    <CMSWrapper data={data} schema={layoutRowSchema}>
      {(props) => {
        const isHero = props.hero;

        return (
          <LayoutRow
            {...{ ...props, ...props.background, isHero }}
            additionalInfo={props.supportingText}
            items={props.items.map((item, index) => {
              const hasContent = item.header || item.imageAsset;
              const minHeight =
                isHero || !hasContent ? "min-h-[460px]" : "min-h-[176px]";

              return (
                <ContentItem
                  key={index}
                  {...item}
                  hasParallaxEffect={isHero && !!item.backgroundImage}
                  wrapperClassName={
                    isHero ? `max-h-[620px] ${minHeight}` : minHeight
                  }
                />
              );
            })}
          />
        );
      }}
    </CMSWrapper>
  );
}
