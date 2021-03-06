/* eslint-disable class-methods-use-this */

import { Italic as BaseItalic } from 'tiptap-extensions';
import { defaultMarkdownSerializer } from '~/lib/prosemirror_markdown_serializer';

// Transforms generated HTML back to GFM for Banzai::Filter::MarkdownFilter
export default class Italic extends BaseItalic {
  get toMarkdown() {
    return defaultMarkdownSerializer.marks.em;
  }
}
